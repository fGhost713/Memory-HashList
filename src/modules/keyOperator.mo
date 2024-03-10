import Blob "mo:base/Blob";
import HashTableTypes "../types/hashListTypes";
import StableTrieMap "mo:StableTrieMap";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Region "mo:base/Region";
import Iter "mo:base/Iter";
import List "mo:base/List";
import Binary "../helpers/binary";
import Itertools "mo:itertools/Iter";
import Option "mo:base/Option";
import Debug "mo:base/Debug";
import { MemoryRegion } "mo:memory-region";
import GlobalFunctions "../helpers/globalFunctions";

module {
          
    private type MemoryStorage = HashTableTypes.MemoryStorage;

    // The key-operations for the hashlist-key are defined here
    public class keyOperator(memoryStorageToUse : MemoryStorage){

        private let memoryStorage : MemoryStorage = memoryStorageToUse;
        private var blobHashFunction = GlobalFunctions.blobHash;
        private var nat32IdentityFunction = GlobalFunctions.nat32Identity;

        // Remove key from index-mapping list
        public func remove_value(hashedKey:Nat32, valueToRemove : Nat64) {

    
            let memoryAddressesOrNull = StableTrieMap.get(memoryStorage.index_mappings, Nat32.equal, nat32IdentityFunction, hashedKey);
            switch (memoryAddressesOrNull) {
                case (?memoryAddresses) {
                    let newList = List.filter<Nat64>(memoryAddresses, func n { n != valueToRemove });
                    if (List.size(newList) == 0) {
                        StableTrieMap.delete(memoryStorage.index_mappings, Nat32.equal, nat32IdentityFunction, hashedKey);
                    } else {
                        StableTrieMap.put(memoryStorage.index_mappings, Nat32.equal, nat32IdentityFunction, hashedKey, newList);
                    };
                };
                case (_) {
                    StableTrieMap.delete(memoryStorage.index_mappings, Nat32.equal, nat32IdentityFunction, hashedKey);
                };
            };
        };

        // Get keyinfo-memory adresses for a provided key
        public func get_values(hashedKey:Nat32):List.List<Nat64>{
            
            let memoryAddressesOrNull = StableTrieMap.get(memoryStorage.index_mappings, Nat32.equal, nat32IdentityFunction, hashedKey);
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
