import LibKeyInfo "libKeyInfo";
import LibWrappedBlob "libWrappedBlob";
import LibKey "libKey";
import Option "mo:base/Option";
import Result "mo:base/Result";
import Nat64 "mo:base/Nat64";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Array "mo:base/Array";
import GlobalFunctions "../helpers/globalFunctions";
import MemoryStorageTypes "../types/memoryStorage/memoryStorageTypes";
import LibIndex "libIndex";
import Vector "mo:vector";

module {

        private type MemoryStorage = MemoryStorageTypes.MemoryStorage;
        private let blobHashFunction = GlobalFunctions.blobHash;
        private let nat32IdentityFunction = GlobalFunctions.nat32Identity;

        public func add_many(memoryStorage:MemoryStorage,key : Blob, values : [Blob]) {

            for (item : Blob in Iter.fromArray(values)) {
                ignore add(memoryStorage,key, item);
            };
        };

        // adding new value for specified key (if key is not existing it is created)
        public func add(memoryStorage:MemoryStorage,key : Blob, value : Blob) : (Nat /*index*/, Nat64 /* wrapped-blob address*/) {
            let hashedKey : Nat32 = blobHashFunction(key);

            let keyInfoAddressResult = LibKeyInfo.get_keyinfo_address(memoryStorage,key);
            let keyInfoWasFound = keyInfoAddressResult.0;
            let keyInfoAddress = keyInfoAddressResult.1;

            if (keyInfoWasFound == false) {
                //Key not exist

                // store the blob (with no previous and next item specified, because it is now the first item):
                let wrappedBlobMemoryAddress = LibWrappedBlob.create_new(memoryStorage,value, null, null);

                // create and get new outer-vector index:
                let outerVectorIndex : Nat = LibIndex.add_outer_vector(memoryStorage);

                // Add new wrappedblob-address
                LibIndex.append_wrapped_blob_memory_address(memoryStorage,outerVectorIndex, wrappedBlobMemoryAddress);

                // create corresponding key-info
                let newKeyInfoAddress = LibKeyInfo.create_new(memoryStorage,key, Nat64.fromNat(outerVectorIndex));

                // Push libKeyInfo-Address as value for the specified key
                LibKey.add_entry(memoryStorage,hashedKey, newKeyInfoAddress);

                // return the index for the added value and the new wrapped-blob memory address
                (Option.get(LibIndex.get_last_index(memoryStorage,outerVectorIndex), 0), wrappedBlobMemoryAddress);

            } else {

                let outer_vector_indexNat64 : Nat64 = LibKeyInfo.get_related_outer_vector_index(memoryStorage,keyInfoAddress);
                let outer_vector_index_Nat : Nat = Nat64.toNat(outer_vector_indexNat64);
                let lastWrappedAddressOrNull = LibIndex.get_address_of_last_stored_wrapped_blob(memoryStorage,outer_vector_index_Nat);

                switch (lastWrappedAddressOrNull) {
                    case (?lastWrappedAddress) {

                        // create new wrapped-blob:
                        let wrappedBlobMemoryAddress = LibWrappedBlob.create_new(
                            memoryStorage,
                            value,
                            Option.make(lastWrappedAddress),
                            null,
                        );

                        // update next-address of previous wrapped-blob
                        LibWrappedBlob.update_next_wrapped_blob_address_value(memoryStorage,lastWrappedAddress, wrappedBlobMemoryAddress);

                        // add wrapped-blob address vector
                        LibIndex.append_wrapped_blob_memory_address(memoryStorage,outer_vector_index_Nat, wrappedBlobMemoryAddress);

                        // return the index for the added value and the new wrapped-blob memory address
                        (Option.get(LibIndex.get_last_index(memoryStorage, outer_vector_index_Nat), 0), wrappedBlobMemoryAddress);

                    };
                    case (_) {
                        // we need to create new

                        // store the blob (with no previous and next item specified, because it is now the first item):
                        let wrappedBlobMemoryAddress = LibWrappedBlob.create_new(memoryStorage,value, null, null);

                        // create and get new outer-vector index:
                        let outerVectorIndex : Nat = LibIndex.add_outer_vector(memoryStorage);

                        // Add new wrappedblob-address
                        LibIndex.append_wrapped_blob_memory_address(memoryStorage,outerVectorIndex, wrappedBlobMemoryAddress);

                        // set the outer-vector-index in related keyinfo
                        LibKeyInfo.set_related_outer_vector_index(memoryStorage,keyInfoAddress, Nat64.fromNat(outerVectorIndex));

                        // return the index for the added value and the new wrapped-blob memory address
                        (Option.get(LibIndex.get_last_index(memoryStorage,outerVectorIndex), 0), wrappedBlobMemoryAddress);
                    };

                };

            };
        };

        // Returns all the used keys (as blob)
        public func get_all_keys(memoryStorage:MemoryStorage,) : [Blob] {
            LibKeyInfo.get_all_keys(memoryStorage);
        };

        // Overwrites the existing blob at specified index
        public func update_at_index(memoryStorage:MemoryStorage,key : Blob, index : Nat, newBlob : Blob) : Result.Result<Text, Text> {
            let wrappedBlobAddressOrNull = get_wrapped_blob_address_at_index(memoryStorage,key, index);
            switch (wrappedBlobAddressOrNull) {
                case (?foundWrappedBlobAddress) {
                    LibWrappedBlob.update_inner_blob(memoryStorage,foundWrappedBlobAddress, newBlob);
                    #ok("The value was updated.");
                };
                case (_) {
                    #err("Existing value not found for this key at index " #debug_show (index));
                };
            };
        };

        public func insert_many_at_index(memoryStorage:MemoryStorage,key : Blob, index : Nat, blobs : [Blob]) : Result.Result<Text, Text> {

            if (Array.size(blobs) == 0) {
                return #err("no blobs to add.");
            };
            if (Array.size(blobs) == 1) {
                let res = insert_at_index(memoryStorage,key, index, blobs[0]);
                switch (res) {
                    case (#ok(number)) {
                        return #ok("");
                    };
                    case (#err(text)) {
                        return #err(text);
                    };
                };
            };

            let keyInfoAddressResult = LibKeyInfo.get_keyinfo_address(memoryStorage,key);
            let keyInfoWasFound = keyInfoAddressResult.0;
            let keyInfoAddress = keyInfoAddressResult.1;
            if (index == 0 and keyInfoWasFound == false) {
                add_many(memoryStorage,key, blobs);
                return #ok("");
            };

            if (keyInfoWasFound == false) {
                return #err("Index not found.");
            };

            let outer_vector_index = LibKeyInfo.get_related_outer_vector_index(memoryStorage,keyInfoAddress);
            let wrappedBlobAddressOrNull = LibIndex.get_wrapped_blob_Address(
                memoryStorage,
                Nat64.toNat(outer_vector_index),
                index,
            );

            let newWrappedBlobAddresses : Vector.Vector<Nat64> = Vector.new();

            switch (wrappedBlobAddressOrNull) {
                case (?foundWrappedBlobAddress) {

                    for (blob : Blob in Iter.fromArray(blobs)) {
                        let insertBlobResult = LibWrappedBlob.create_and_insert_new_wrapped_blob(memoryStorage,foundWrappedBlobAddress, blob);
                        Vector.add(newWrappedBlobAddresses, insertBlobResult.1);
                    };
                };
                case (_) {
                    return #err("Index not found.");
                };
            };

            if (Vector.size(newWrappedBlobAddresses) > 0) {
                let newAddresses = Vector.toArray(newWrappedBlobAddresses);
                LibIndex.insert_many_at_index(memoryStorage,Nat64.toNat(outer_vector_index), index, newAddresses);
            };

            return #ok("");
        };

        // Insert blob-value at index
        public func insert_at_index(memoryStorage:MemoryStorage,key : Blob, index : Nat, newBlob : Blob) : Result.Result<Nat64, Text> {

            let keyInfoAddressResult = LibKeyInfo.get_keyinfo_address(memoryStorage,key);
            let keyInfoWasFound = keyInfoAddressResult.0;
            let keyInfoAddress = keyInfoAddressResult.1;
            if (index == 0 and keyInfoWasFound == false) {
                let result = add(memoryStorage,key, newBlob);
                return #ok(result.1);
            };

            if (keyInfoWasFound == false) {
                return #err("Index not found.");
            };

            let outer_vector_index = LibKeyInfo.get_related_outer_vector_index(memoryStorage,keyInfoAddress);
            let wrappedBlobAddressOrNull = LibIndex.get_wrapped_blob_Address(
                memoryStorage,
                Nat64.toNat(outer_vector_index),
                index,
            );

            switch (wrappedBlobAddressOrNull) {
                case (?foundWrappedBlobAddress) {
                    let insertBlobResult = LibWrappedBlob.create_and_insert_new_wrapped_blob(memoryStorage,foundWrappedBlobAddress, newBlob);
                    LibIndex.insert_at_index(memoryStorage,Nat64.toNat(outer_vector_index), index, insertBlobResult.1);
                    return #ok(insertBlobResult.1);
                };
                case (_) {
                    return #err("Index not found.");
                };
            };
        };

        // Removes values for the key from 'firstIndex' to 'lastIndex'
        public func remove_at_range(memoryStorage:MemoryStorage,key : Blob, startIndex : Nat, lastIndexOrNull : ?Nat) : Result.Result<Text, Text> {

            let hashedKey : Nat32 = blobHashFunction(key);
            let keyInfoAddressResult = LibKeyInfo.get_keyinfo_address(memoryStorage,key);
            let keyInfoWasFound = keyInfoAddressResult.0;
            let keyInfoAddress = keyInfoAddressResult.1;

            if (keyInfoWasFound == false) {
                return #err("Existing value not found for this key at index: " #debug_show (startIndex));
            };

            let outer_vector_index : Nat64 = LibKeyInfo.get_related_outer_vector_index(memoryStorage,keyInfoAddress);
            let realLastIndexOrNull = LibIndex.get_last_index(memoryStorage,Nat64.toNat(outer_vector_index));

            switch (realLastIndexOrNull) {
                case (?realLastIndex) {

                    if (startIndex > realLastIndex) {
                        return #err("Existing value not found for this key at index: " #debug_show (startIndex));
                    };

                    var endIndexToUse = 0;

                    switch (lastIndexOrNull) {
                        case (?lastIndex) {
                            endIndexToUse := Nat.min(lastIndex, realLastIndex);
                        };
                        case (_) {
                            endIndexToUse := realLastIndex;
                        };
                    };

                    if (endIndexToUse < startIndex) {
                        return #err("LastIndex must not be greater than startIndex.");
                    };

                    let startWrappedBlobAddressOrNull = LibIndex.get_wrapped_blob_Address(
                        memoryStorage,
                        Nat64.toNat(outer_vector_index),
                        startIndex,
                    );

                    let endWrappedBlobAddressOrNull = LibIndex.get_wrapped_blob_Address(
                        memoryStorage,
                        Nat64.toNat(outer_vector_index),
                        endIndexToUse,
                    );

                    switch (startWrappedBlobAddressOrNull) {
                        case (?wrappedBlobStartAddress) {

                            ignore LibWrappedBlob.delete_wrapped_blobs(memoryStorage,wrappedBlobStartAddress, endWrappedBlobAddressOrNull);
                            LibIndex.remove_at_range(memoryStorage,Nat64.toNat(outer_vector_index), startIndex, endIndexToUse);
                            let newLastInnerVectorIndex = LibIndex.get_last_index(memoryStorage,Nat64.toNat(outer_vector_index));
                            if (newLastInnerVectorIndex == null) {
                                // no values available -> We can remove the complete key

                                // delete value from hashed-key.
                                // (and key is also removed if it was the last keyinfo-address for the hashed-key)
                                LibKey.remove_value(memoryStorage,hashedKey, keyInfoAddress);

                                // delete the keyinfo from memory
                                LibKeyInfo.delete(memoryStorage,keyInfoAddress);

                                // clear the vector outer-index
                                LibIndex.empty_inner_vector(memoryStorage,Nat64.toNat(outer_vector_index));
                            };

                            return #ok("");

                        };
                        case (_) {
                            return #err("Could not find the related memory address.");
                        };
                    };

                };
                case (_) {
                    return #err("Existing value not found for this key at index: " #debug_show (startIndex));
                };
            };
        };

        // Removes value for the key at specific index position
        public func remove_at_index(memoryStorage:MemoryStorage,key : Blob, index : Nat) : Result.Result<Text, Text> {

            //return remove_at_range(key, index, Option.make(index));

            let hashedKey : Nat32 = blobHashFunction(key);
            let keyInfoAddressResult = LibKeyInfo.get_keyinfo_address(memoryStorage,key);
            let keyInfoWasFound = keyInfoAddressResult.0;
            let keyInfoAddress = keyInfoAddressResult.1;

            if (keyInfoWasFound == false) {
                return #err("Existing value not found for this key at index: " #debug_show (index));
            };

            let outer_vector_index = LibKeyInfo.get_related_outer_vector_index(memoryStorage,keyInfoAddress);
            let wrappedBlobAddressOrNull = LibIndex.get_wrapped_blob_Address(
                memoryStorage,
                Nat64.toNat(outer_vector_index),
                index,
            );

            switch (wrappedBlobAddressOrNull) {
                case (?foundWrappedBlobAddress) {

                    let wasLastElement = LibWrappedBlob.delete_wrapped_blob(memoryStorage,foundWrappedBlobAddress);
                    if (index == 0 and wasLastElement == true) {

                        // we can delete all for the key

                        // delete value from hashed-key.
                        // (and key is also removed if it was the last keyinfo-address for the hashed-key)
                        LibKey.remove_value(memoryStorage,hashedKey, keyInfoAddress);

                        // delete the keyinfo from memory
                        LibKeyInfo.delete(memoryStorage,keyInfoAddress);

                        // clear the vector outer-index
                        LibIndex.empty_inner_vector(memoryStorage,Nat64.toNat(outer_vector_index));

                        return #ok("The value was removed.");
                    };

                    LibIndex.remove_at_index(memoryStorage,Nat64.toNat(outer_vector_index), index);
                    #ok("The value was removed.");
                };
                case (_) {
                    #err("Existing value not found for this key at index: " #debug_show (index));
                };
            };
        };

        // removes the key and all the added values to this key
        public func remove_key(memoryStorage:MemoryStorage,key : Blob) {

            let hashedKey : Nat32 = blobHashFunction(key);
            let keyInfoAddressResult = LibKeyInfo.get_keyinfo_address(memoryStorage,key);
            let keyInfoWasFound = keyInfoAddressResult.0;
            let keyInfoAddress = keyInfoAddressResult.1;

            if (keyInfoWasFound == false) {
                return;
            };

            let outerIndex : Nat64 = LibKeyInfo.get_related_outer_vector_index(memoryStorage,keyInfoAddress);
            let outerIndexNat : Nat = Nat64.toNat(outerIndex);
            let firstWrappedBlobAddressOrNull = LibIndex.get_wrapped_blob_Address(memoryStorage,outerIndexNat, 0);

            switch (firstWrappedBlobAddressOrNull) {
                case (?firstWrappedBlobAddress) {
                    ignore LibWrappedBlob.delete_wrapped_blobs(memoryStorage,firstWrappedBlobAddress, null);
                };
                case (_) {

                };
            };

            // delete value from hashed-key.
            // (and key is also removed if it was the last keyinfo-address for the hashed-key)
            LibKey.remove_value(memoryStorage,hashedKey, keyInfoAddress);

            // delete the keyinfo from memory
            LibKeyInfo.delete(memoryStorage,keyInfoAddress);

            // clear the vector outer-index
            LibIndex.empty_inner_vector(memoryStorage,Nat64.toNat(outerIndex));

        };

        public func get_at_index(memoryStorage:MemoryStorage,key : Blob, innerIndex : Nat) : ?Blob {

            let wrappedBlobAddressOrNull = get_wrapped_blob_address_at_index(memoryStorage,key, innerIndex);
            switch (wrappedBlobAddressOrNull) {
                case (?wrappedBlobAddress) {
                    let innerBlob : Blob = LibWrappedBlob.get_inner_blob_from_wrapped_blob_Address(memoryStorage,wrappedBlobAddress);
                    return ?innerBlob;
                };
                case (_) {
                    return null;
                };
            };
        };

        public func get_at_range(memoryStorage:MemoryStorage,key : Blob, firstIndex : Nat, lastIndex : Nat) : [Blob] {

            let lastIndexOrNull : ?Nat = get_last_index(memoryStorage,key);
            switch (lastIndexOrNull) {
                case (?foundLastIndex) {
                    if (firstIndex > foundLastIndex or firstIndex > lastIndex) {
                        return [];
                    };
                    let lastIndexToUse : Nat = Nat.min(lastIndex, foundLastIndex);
                    let vector : Vector.Vector<Blob> = Vector.new();
                    let firstItemResult = get_internal_blob_and_next_address_at_index_internal(memoryStorage,key, firstIndex);

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
                                let innerBlob = LibWrappedBlob.get_inner_blob_from_wrapped_blob_Address(memoryStorage,nextAddress);
                                Vector.add(vector, innerBlob);

                                let nextAddressResult = LibWrappedBlob.get_next_wrapped_blob_address(memoryStorage,nextAddress);
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
        public func get_last_index(memoryStorage:MemoryStorage,key : Blob) : ?Nat {
            let keyInfoAddressResult = LibKeyInfo.get_keyinfo_address(memoryStorage,key);
            let keyInfoWasFound = keyInfoAddressResult.0;
            let keyInfoAddress = keyInfoAddressResult.1;

            if (keyInfoWasFound == false) {
                return null;
            };

            let outer_vector_index = LibKeyInfo.get_related_outer_vector_index(memoryStorage,keyInfoAddress);
            LibIndex.get_last_index(memoryStorage,Nat64.toNat(outer_vector_index));
        };

        // Helper functions:

        private func get_internal_blob_and_next_address_at_index_internal(memoryStorage:MemoryStorage,key : Blob, innerIndex : Nat) : (?Blob, ?Nat64) {

            let wrappedBlobAddressOrNull = get_wrapped_blob_address_at_index(memoryStorage,key, innerIndex);

            switch (wrappedBlobAddressOrNull) {
                case (?wrappedBlobAddress) {
                    let innerBlob : Blob = LibWrappedBlob.get_inner_blob_from_wrapped_blob_Address(memoryStorage,wrappedBlobAddress);
                    let nextWrappedBlobAddress = LibWrappedBlob.get_next_wrapped_blob_address(memoryStorage,wrappedBlobAddress);
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

        private func get_wrapped_blob_address_at_index(memoryStorage:MemoryStorage,key : Blob, innerIndex : Nat) : ?Nat64 {

            let keyInfoAddressResult = LibKeyInfo.get_keyinfo_address(memoryStorage,key);
            let keyInfoWasFound = keyInfoAddressResult.0;
            let keyInfoAddress = keyInfoAddressResult.1;

            if (keyInfoWasFound == false) {
                return null;
            };

            let outer_vector_index = LibKeyInfo.get_related_outer_vector_index(memoryStorage,keyInfoAddress);
            LibIndex.get_wrapped_blob_Address(
                memoryStorage,
                Nat64.toNat(outer_vector_index),
                innerIndex,
            );
        };

  

};
