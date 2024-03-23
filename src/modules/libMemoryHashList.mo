import LibKeyInfo "libKeyInfo";
import LibWrappedBlob "libWrappedBlob";
import LibKey "libKey";
import Option "mo:base/Option";
import Result "mo:base/Result";
import Nat64 "mo:base/Nat64";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import GlobalFunctions "../helpers/globalFunctions";
import MemoryStorageTypes "../types/memoryStorage/memoryStorageTypes";
import LibIndex "libIndex";
import Vector "mo:vector";

module {

    public class libMemoryHashList(memoryStorageToUse : MemoryStorageTypes.MemoryStorage) {
        private let memoryStorage : MemoryStorageTypes.MemoryStorage = memoryStorageToUse;

        private let libKey = LibKey.libKey(memoryStorageToUse);
        private let libWrappedBlob = LibWrappedBlob.libWrappedBlob(memoryStorageToUse);
        private let libKeyInfo = LibKeyInfo.libKeyInfo(memoryStorageToUse);
        private let libIndex = LibIndex.libIndex(memoryStorageToUse);

        private var blobHashFunction = GlobalFunctions.blobHash;
        private var nat32IdentityFunction = GlobalFunctions.nat32Identity;

        // This function is useful for tests, so that we can define the
        // blob-to-hash function. With this we can forcefully simulate hash collisions in the tests later.
        public func setBlobHashingFunction(blobHash : Blob -> Nat32) {
            blobHashFunction := blobHash;
            libKey.setBlobHashingFunction(blobHash);
            libKeyInfo.setBlobHashingFunction(blobHash);
        };

        // adding new value for specified key (if key is not existing it is created)
        public func add(key : Blob, value : Blob) : (Nat /*index*/, Nat64 /* wrapped-blob address*/) {
            let hashedKey : Nat32 = blobHashFunction(key);

            let keyInfoAddressResult = libKeyInfo.get_keyinfo_address(key);
            let keyInfoWasFound = keyInfoAddressResult.0;
            let keyInfoAddress = keyInfoAddressResult.1;

            if (keyInfoWasFound == false) {
                //Key not exist

                // store the blob (with no previous and next item specified, because it is now the first item):
                let wrappedBlobMemoryAddress = libWrappedBlob.create_new(value, null, null);

                // create and get new outer-vector index:
                let outerVectorIndex : Nat = libIndex.add_outer_vector();

                // Add new wrappedblob-address
                libIndex.append_wrapped_blob_memory_address(outerVectorIndex, wrappedBlobMemoryAddress);

                // create corresponding key-info
                let newKeyInfoAddress = libKeyInfo.create_new(key, Nat64.fromNat(outerVectorIndex));

                // Push libKeyInfo-Address as value for the specified key
                libKey.add_entry(hashedKey, newKeyInfoAddress);

                // return the index for the added value and the new wrapped-blob memory address
                (Option.get(libIndex.get_last_index(outerVectorIndex), 0), wrappedBlobMemoryAddress);

            } else {

                let outer_vector_indexNat64 : Nat64 = libKeyInfo.get_related_outer_vector_index(keyInfoAddress);
                let outer_vector_index_Nat : Nat = Nat64.toNat(outer_vector_indexNat64);
                let lastWrappedAddressOrNull = libIndex.get_address_of_last_stored_wrapped_blob(outer_vector_index_Nat);

                switch (lastWrappedAddressOrNull) {
                    case (?lastWrappedAddress) {

                        // create new wrapped-blob:
                        let wrappedBlobMemoryAddress = libWrappedBlob.create_new(
                            value,
                            Option.make(lastWrappedAddress),
                            null,
                        );

                        // update next-address of previous wrapped-blob
                        libWrappedBlob.update_next_wrapped_blob_address_value(lastWrappedAddress, wrappedBlobMemoryAddress);

                        // add wrapped-blob address vector
                        libIndex.append_wrapped_blob_memory_address(outer_vector_index_Nat, wrappedBlobMemoryAddress);

                        // return the index for the added value and the new wrapped-blob memory address
                        (Option.get(libIndex.get_last_index(outer_vector_index_Nat), 0), wrappedBlobMemoryAddress);

                    };
                    case (_) {
                        // we need to create new

                        // store the blob (with no previous and next item specified, because it is now the first item):
                        let wrappedBlobMemoryAddress = libWrappedBlob.create_new(value, null, null);

                        // create and get new outer-vector index:
                        let outerVectorIndex : Nat = libIndex.add_outer_vector();

                        // Add new wrappedblob-address
                        libIndex.append_wrapped_blob_memory_address(outerVectorIndex, wrappedBlobMemoryAddress);

                        // set the outer-vector-index in related keyinfo
                        libKeyInfo.set_related_outer_vector_index(keyInfoAddress, Nat64.fromNat(outerVectorIndex));

                        // return the index for the added value and the new wrapped-blob memory address
                        (Option.get(libIndex.get_last_index(outerVectorIndex), 0), wrappedBlobMemoryAddress);
                    };

                };

            };
        };

        // Returns all the used keys (as blob)
        public func get_all_keys() : [Blob] {
            libKeyInfo.get_all_keys();
        };

        // overwrites the existing blob at specified index
        public func update_at_index(key : Blob, index : Nat, newBlob : Blob) : Result.Result<Text, Text> {
            let wrappedBlobAddressOrNull = get_wrapped_blob_address_at_index(key, index);
            switch (wrappedBlobAddressOrNull) {
                case (?foundWrappedBlobAddress) {
                    libWrappedBlob.update_inner_blob(foundWrappedBlobAddress, newBlob);
                    #ok("The value was updated.");
                };
                case (_) {
                    #err("Existing value not found for this key at index " #debug_show (index));
                };
            };
        };

        public func insert_at_index(key : Blob, index : Nat, newBlob : Blob) : Result.Result<Nat64, Text> {

            let keyInfoAddressResult = libKeyInfo.get_keyinfo_address(key);
            let keyInfoWasFound = keyInfoAddressResult.0;
            let keyInfoAddress = keyInfoAddressResult.1;
            if (index == 0 and keyInfoWasFound == false) {
                let result = add(key, newBlob);
                return #ok(result.1);
            };

            if (keyInfoWasFound == false) {
                return #err("Index not found.");
            };

            let outer_vector_index = libKeyInfo.get_related_outer_vector_index(keyInfoAddress);
            let wrappedBlobAddressOrNull = libIndex.get_wrapped_blob_Address(
                Nat64.toNat(outer_vector_index),
                index,
            );

            switch (wrappedBlobAddressOrNull) {
                case (?foundWrappedBlobAddress) {
                    let insertBlobResult = libWrappedBlob.create_and_insert_new_wrapped_blob(foundWrappedBlobAddress, newBlob);
                    libIndex.insert_at_index(Nat64.toNat(outer_vector_index), index, insertBlobResult.1);
                    return #ok(insertBlobResult.1);
                };
                case (_) {
                    return #err("Index not found.");
                };
            };
        };

        public func remove_at_index(key : Blob, index : Nat) : Result.Result<Text, Text> {

            let hashedKey : Nat32 = blobHashFunction(key);
            let keyInfoAddressResult = libKeyInfo.get_keyinfo_address(key);
            let keyInfoWasFound = keyInfoAddressResult.0;
            let keyInfoAddress = keyInfoAddressResult.1;

            if (keyInfoWasFound == false) {
                return #err("Existing value not found for this key at index: " #debug_show (index));
            };

            let outer_vector_index = libKeyInfo.get_related_outer_vector_index(keyInfoAddress);
            let wrappedBlobAddressOrNull = libIndex.get_wrapped_blob_Address(
                Nat64.toNat(outer_vector_index),
                index,
            );

            switch (wrappedBlobAddressOrNull) {
                case (?foundWrappedBlobAddress) {

                    let wasLastElement = libWrappedBlob.delete_wrapped_blob(foundWrappedBlobAddress);
                    if (index == 0 and wasLastElement == true) {

                        // we can delete all for the key

                        // delete value from hashed-key.
                        // (and key is also removed if it was the last keyinfo-adress for the hashed-key)
                        libKey.remove_value(hashedKey, keyInfoAddress);

                        // delete the keyinfo from memory
                        libKeyInfo.delete(keyInfoAddress);

                        // clear the vector outer-index
                        libIndex.empty_inner_vector(Nat64.toNat(outer_vector_index));

                        return #ok("The value was removed.");
                    };

                    libIndex.remove_at_index(Nat64.toNat(outer_vector_index), index);
                    #ok("The value was removed.");
                };
                case (_) {
                    #err("Existing value not found for this key at index: " #debug_show (index));
                };
            };
        };

        public func get_at_index(key : Blob, innerIndex : Nat) : ?Blob {

            let wrappedBlobAddressOrNull = get_wrapped_blob_address_at_index(key, innerIndex);
            switch (wrappedBlobAddressOrNull) {
                case (?wrappedBlobAddress) {
                    let innerBlob : Blob = libWrappedBlob.get_inner_blob_from_wrapped_blob_Address(wrappedBlobAddress);
                    return ?innerBlob;
                };
                case (_) {
                    return null;
                };
            };
        };

        public func get_at_range(key : Blob, firstIndex : Nat, lastIndex : Nat) : [Blob] {

            let lastIndexOrNull : ?Nat = get_last_index(key);
            switch (lastIndexOrNull) {
                case (?foundLastIndex) {
                    if (firstIndex > foundLastIndex or firstIndex > lastIndex) {
                        return [];
                    };
                    let lastIndexToUse : Nat = Nat.min(lastIndex, foundLastIndex);
                    let vector : Vector.Vector<Blob> = Vector.new();
                    let firstItemResult = get_internal_blob_and_next_address_at_index_internal(key, firstIndex);

                    switch (firstItemResult.0) {
                        case (?foundBlob) {
                            Vector.add<Blob>(vector, foundBlob);
                        };
                        case (_) {
                            return [];
                        };

                    };

                    var nextAddress : Nat64 = 0;

                    switch (firstItemResult.1) {
                        case (?foundNextAddress) {
                            nextAddress := foundNextAddress;
                        };
                        case (_) {
                            return Vector.toArray(vector);
                        };
                    };

                    var nextAddressFound = true;

                    if ((firstIndex +1) <= lastIndexToUse) {

                        for (index in Iter.range(firstIndex +1, lastIndexToUse)) {

                            if (nextAddressFound == true) {
                                let innerBlob = libWrappedBlob.get_inner_blob_from_wrapped_blob_Address(nextAddress);
                                Vector.add(vector, innerBlob);

                                let nextAddressResult = libWrappedBlob.get_next_wrapped_blob_address(nextAddress);
                                if (nextAddressResult.0 == true) {
                                    nextAddress := nextAddressResult.1;
                                } else {
                                    nextAddressFound := false;
                                };
                            };
                        };

                    };

                    return Vector.toArray(vector);

                };
                case (_) {
                    return [];
                };
            };
        };

        // return last index or null if empty
        public func get_last_index(key : Blob) : ?Nat {
            let keyInfoAddressResult = libKeyInfo.get_keyinfo_address(key);
            let keyInfoWasFound = keyInfoAddressResult.0;
            let keyInfoAddress = keyInfoAddressResult.1;

            if (keyInfoWasFound == false) {
                return null;
            };

            let outer_vector_index = libKeyInfo.get_related_outer_vector_index(keyInfoAddress);
            libIndex.get_last_index(Nat64.toNat(outer_vector_index));
        };

        // Helper functions:

        private func get_internal_blob_and_next_address_at_index_internal(key : Blob, innerIndex : Nat) : (?Blob, ?Nat64) {

            let wrappedBlobAddressOrNull = get_wrapped_blob_address_at_index(key, innerIndex);

            switch (wrappedBlobAddressOrNull) {
                case (?wrappedBlobAddress) {
                    let innerBlob : Blob = libWrappedBlob.get_inner_blob_from_wrapped_blob_Address(wrappedBlobAddress);
                    let nextWrappedBlobAddress = libWrappedBlob.get_next_wrapped_blob_address(wrappedBlobAddress);
                    if (nextWrappedBlobAddress.0 == false) {
                        return (?innerBlob, null);
                    } else {
                        return (?innerBlob, ?nextWrappedBlobAddress.1);
                    };

                };
                case (_) {
                    return (null, null);
                };
            };
        };

        private func get_wrapped_blob_address_at_index(key : Blob, innerIndex : Nat) : ?Nat64 {

            let keyInfoAddressResult = libKeyInfo.get_keyinfo_address(key);
            let keyInfoWasFound = keyInfoAddressResult.0;
            let keyInfoAddress = keyInfoAddressResult.1;

            if (keyInfoWasFound == false) {
                return null;
            };

            let outer_vector_index = libKeyInfo.get_related_outer_vector_index(keyInfoAddress);
            libIndex.get_wrapped_blob_Address(
                Nat64.toNat(outer_vector_index),
                innerIndex,
            );
        };

    };

};
