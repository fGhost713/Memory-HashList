import Blob "mo:base/Blob";
import Nat64 "mo:base/Nat64";
import Region "mo:base/Region";
import List "mo:base/List";
import Nat32 "mo:base/Nat32";
import Option "mo:base/Option";
import GlobalFunctions "../helpers/globalFunctions";
import CommonTypes "../types/commonTypes";
import LibKey "libKey";
import Vector "mo:vector";

module {

    private let blobHashFunction = GlobalFunctions.blobHash;
    private let nat32IdentityFunc = GlobalFunctions.nat32Identity;
    private let offset = CommonTypes.Offsets_KeyInfo;
    private type MemoryStorage = CommonTypes.MemoryStorage;

    // Returns true if on this memory location keyinfo is stored
    public func is_keyinfo_on_that_address(memoryStorage : MemoryStorage, keyinfoAddress : Nat64) : Bool {
        let identifier = Region.loadNat64(memoryStorage.memory_region.region, keyinfoAddress + offset.identifier);
        return identifier == CommonTypes.identifier_KeyInfo;
    };

    // removes the identifier
    public func remove_identifier(memoryStorage : MemoryStorage, keyinfoAddress : Nat64) {
        Region.storeNat64(memoryStorage.memory_region.region, keyinfoAddress + offset.identifier, 0);
    };

    // returns the related vector-outer-index for the key-info (Each key one keyinfo)
    public func get_related_outer_vector_index(memoryStorage : MemoryStorage, keyinfoAddress : Nat64) : Nat64 {
        Region.loadNat64(memoryStorage.memory_region.region, keyinfoAddress + offset.vectorIndex);
    };

    // set the outer-vector index in keyinfo. (Directly into memory)
    public func set_related_outer_vector_index(memoryStorage : MemoryStorage, keyinfoAddress : Nat64, outer_vector_index : Nat64) {
        Region.storeNat64(memoryStorage.memory_region.region, keyinfoAddress + offset.vectorIndex, outer_vector_index);
    };

    // returns the keyinfo size
    private func get_keyinfo_size(memoryStorage : MemoryStorage, keyInfoAddress : Nat64) : Nat32 {
        Region.loadNat32(memoryStorage.memory_region.region, keyInfoAddress + offset.totalSize);
    };

    // returns all stored keys. (The real key's as blob's. initially used in hashList.add(key,..))
    public func get_all_keys(memoryStorage : MemoryStorage) : [Blob] {

        let result : Vector.Vector<Blob> = Vector.new();

        let allHashedKeys = LibKey.get_key_hashes(memoryStorage);
        for (hashedKey in allHashedKeys) {
            let keyInfoAddresses = LibKey.get_vals_for_hashed_key(memoryStorage, hashedKey);
            for (keyInfoAddress in List.toIter(keyInfoAddresses)) {
                let keyInfo : ?Blob = get_key(memoryStorage, keyInfoAddress);
                switch (keyInfo) {
                    case (?foundKeyInfo) {
                        Vector.add(result, foundKeyInfo);
                    };
                    case (_) {

                    };
                };

            };
        };
        return Vector.toArray(result);
    };

    // returns the keyinfo-address for that key
    public func get_keyinfo_address(memoryStorage : MemoryStorage, key : Blob) : (Bool, Nat64) {

        let hashedKey : Nat32 = blobHashFunction(key);
        // Get current values for the key
        var memoryAddresses : List.List<Nat64> = LibKey.get_values(memoryStorage, hashedKey);
        var keyInfoWasFound : Bool = false;
        var keyInfoAddress : Nat64 = 0;

        if (List.size(memoryAddresses) > 0) {
            let getKeyInfoAddressResult : (Bool /*found*/, Nat64 /*address*/) = get_correct_keyinfo_address_internal(memoryStorage, key, memoryAddresses);

            keyInfoWasFound := getKeyInfoAddressResult.0;
            keyInfoAddress := getKeyInfoAddressResult.1;
        };

        (keyInfoWasFound, keyInfoAddress);
    };

    // deallocates the keyinfo from memory.
    public func delete(memoryStorage : MemoryStorage, keyInfoAddress : Nat64) {

        if (is_keyinfo_on_that_address(memoryStorage, keyInfoAddress) == false) {
            return;
        };

        remove_identifier(memoryStorage, keyInfoAddress);

        let size : Nat32 = get_keyinfo_size(memoryStorage, keyInfoAddress);
        GlobalFunctions.deallocate(memoryStorage, keyInfoAddress, Nat64.fromNat32(size));
    };

    // Add completely new keyInfo entry for the new key
    public func create_new(memoryStorage : MemoryStorage, key : Blob, vectorIndex : Nat64) : Nat64 {

        let keySize = key.size();
        let sizeNeeded : Nat = Nat64.toNat(offset.minBytesNeeded) + keySize;
        //let sizeNeededNat32 : Nat64 = Nat64.fromNat(sizeNeeded);
        let region = memoryStorage.memory_region.region;

        //allocate memory
        let keyInfoMemoryAddress : Nat = GlobalFunctions.allocate(memoryStorage, Nat64.fromNat(sizeNeeded));
        let keyInfoMemoryNat64 : Nat64 = Nat64.fromNat(keyInfoMemoryAddress);

        // total size
        Region.storeNat32(region, keyInfoMemoryNat64 + offset.totalSize, Nat32.fromNat(sizeNeeded));

        // identifier
        Region.storeNat64(region, keyInfoMemoryNat64 + offset.identifier, CommonTypes.identifier_KeyInfo);

        // version
        Region.storeNat16(region, keyInfoMemoryNat64 + offset.version, CommonTypes.version);

        // the related vector-index
        Region.storeNat64(region, keyInfoMemoryNat64 + offset.vectorIndex, vectorIndex);

        // size of key
        Region.storeNat32(region, keyInfoMemoryNat64 + offset.sizeOfKeyBlob, Nat32.fromNat(keySize));

        // store key as blob
        Region.storeBlob(region, keyInfoMemoryNat64 + offset.keyAsBlob, key);

        return keyInfoMemoryNat64;
    };

    // Helper functions

    private func get_key(memoryStorage : MemoryStorage, keyInfoAddress : Nat64) : ?Blob {
        let sizeOfKey : Nat32 = Region.loadNat32(memoryStorage.memory_region.region, keyInfoAddress + offset.sizeOfKeyBlob);

        if (is_keyinfo_on_that_address(memoryStorage, keyInfoAddress) == false) {
            return null;
        };

        let result = Region.loadBlob(
            memoryStorage.memory_region.region,
            keyInfoAddress + offset.keyAsBlob,
            Nat32.toNat(sizeOfKey),
        );
        return Option.make(result);
    };

    private func get_correct_keyinfo_address_internal(
        memoryStorage : MemoryStorage,
        key : Blob,
        possibleAddresses : List.List<Nat64>,
    ) : (Bool /*found*/, Nat64 /*address*/) {
        if (List.size<Nat64>(possibleAddresses) == 0) {
            return (false, 0);
        };
        let region = memoryStorage.memory_region.region;
        let keySize : Nat = key.size();
        let keySizeNat32 : Nat32 = Nat32.fromNat(keySize);

        for (address : Nat64 in List.toIter<Nat64>(possibleAddresses)) {

            if (is_keyinfo_on_that_address(memoryStorage, address) == true) {
                let sizeOfKey : Nat32 = Region.loadNat32(region, address + offset.sizeOfKeyBlob);
                if (sizeOfKey == keySizeNat32) {
                    let keyBlob = Region.loadBlob(region, address + offset.keyAsBlob, keySize);
                    if (Blob.equal(keyBlob, key) == true) {
                        return (true, address);
                    };
                };
            };
        };

        return (false, 0);
    };

};
