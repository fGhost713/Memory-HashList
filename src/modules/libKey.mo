import StableTrieMap "mo:StableTrieMap";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Iter "mo:base/Iter";
import List "mo:base/List";
import Option "mo:base/Option";
import GlobalFunctions "../helpers/globalFunctions";
import CommonTypes "../types/commonTypes";

module {

    private type MemoryStorage = CommonTypes.MemoryStorage;

    // The key-operations for the hashlist-key are defined here.
    // For one key we can have multiple (entrypoint) memory-addresses, because
    // the hashed-key can have collisions. Therefore all the memory entrypoints
    // for a specific key are associated (in List) to this key.
    // The memory entrypoints are memory locations where the 'KeyInfo' blob is stored.
    public class libKey(memoryStorageToUse : MemoryStorage) {

        private let memoryStorage : MemoryStorage = memoryStorageToUse;
        private var blobHashFunction = GlobalFunctions.blobHash;
        private var nat32IdentityFunction = GlobalFunctions.nat32Identity;

        // This function is useful for tests, so that we can define the
        // blob-to-hash function. With this we can forcefully simulate hash collisions in the tests later.
        public func setBlobHashingFunction(blobHash : Blob -> Nat32) {
            blobHashFunction := blobHash;
        };

        // Add the memory-address of the keyinfo into StableTrieMap for the corresponding hashed-key
        public func add_entry(hashedKey : Nat32, keyinfoMemoryAddress : Nat64) {

            let memoryAddressesOrNull : ?List.List<Nat64> = StableTrieMap.get(
                memoryStorage.keyToKeyInfoAddressMappings,
                Nat32.equal,
                nat32IdentityFunction,
                hashedKey,
            );

            switch (memoryAddressesOrNull) {
                case (?memoryAddresses) {
                    // key was existing

                    let foundItemOrNull : ?Nat64 = List.find<Nat64>(memoryAddresses, func n { n == keyinfoMemoryAddress });
                    if (foundItemOrNull == null) {
                        // Only add the value if not already existing
                        let newList = List.push<Nat64>(keyinfoMemoryAddress, memoryAddresses);
                        StableTrieMap.put(memoryStorage.keyToKeyInfoAddressMappings, Nat32.equal, nat32IdentityFunction, hashedKey, newList);
                    };
                };
                case (_) {
                    var newList = List.nil<Nat64>();
                    newList := List.push<Nat64>(keyinfoMemoryAddress, newList);
                    StableTrieMap.put(memoryStorage.keyToKeyInfoAddressMappings, Nat32.equal, nat32IdentityFunction, hashedKey, newList);
                };
            };
        };

        // Returns all the used key-hashes.
        public func get_key_hashes() : Iter.Iter<Nat32> {
            StableTrieMap.keys(memoryStorage.keyToKeyInfoAddressMappings);
        };

        public func get_vals_for_key(key : Blob) : List.List<Nat64> {
            let hashedKey : Nat32 = blobHashFunction(key);
            get_vals_for_hashed_key(hashedKey);
        };

        public func get_vals_for_hashed_key(hashedKey : Nat32) : List.List<Nat64> {
            let result = StableTrieMap.get(memoryStorage.keyToKeyInfoAddressMappings, Nat32.equal, nat32IdentityFunction, hashedKey);
            if (result == null) {
                return List.nil<Nat64>();
            };

            Option.get(result, List.nil<Nat64>());
        };

        // Remove key from index-mapping list
        public func remove_value(hashedKey : Nat32, valueToRemove : Nat64) {
            let memoryAddressesOrNull = StableTrieMap.get(memoryStorage.keyToKeyInfoAddressMappings, Nat32.equal, nat32IdentityFunction, hashedKey);
            switch (memoryAddressesOrNull) {
                case (?memoryAddresses) {
                    let newList = List.filter<Nat64>(memoryAddresses, func n { n != valueToRemove });
                    if (List.size(newList) == 0) {
                        StableTrieMap.delete(memoryStorage.keyToKeyInfoAddressMappings, Nat32.equal, nat32IdentityFunction, hashedKey);
                    } else {
                        StableTrieMap.put(memoryStorage.keyToKeyInfoAddressMappings, Nat32.equal, nat32IdentityFunction, hashedKey, newList);
                    };
                };
                case (_) {
                    StableTrieMap.delete(memoryStorage.keyToKeyInfoAddressMappings, Nat32.equal, nat32IdentityFunction, hashedKey);
                };
            };
        };

        // Get keyinfo-memory adresses for a provided key
        public func get_values(hashedKey : Nat32) : List.List<Nat64> {

            let memoryAddressesOrNull = StableTrieMap.get(memoryStorage.keyToKeyInfoAddressMappings, Nat32.equal, nat32IdentityFunction, hashedKey);
            switch (memoryAddressesOrNull) {
                case (?memoryAddresses) {
                    return memoryAddresses;
                };
                case (_) {
                    return List.nil<Nat64>();
                };
            };

        };
    };

};
