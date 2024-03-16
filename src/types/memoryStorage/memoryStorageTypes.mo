import { MemoryRegion } "mo:memory-region";
import StableTrieMap "mo:StableTrieMap";
import List "mo:base/List";
import Nat64 "mo:base/Nat64";
import Nat32 "mo:base/Nat32";
import Nat16 "mo:base/Nat16";
import Nat8 "mo:base/Nat8";

module{

   public type MemoryStorage = {

        //The used memory region
        memory_region : MemoryRegion.MemoryRegion;

        // The start-indizes for key (as Nat32)
        // There might be more indizies in case of hash-collision (== same Nat32 hashed key) therefore the value as List.
        index_mappings : StableTrieMap.StableTrieMap<Nat32, List.List<Nat64>>;

        // The replace buffer size
        // If value update method is called and the new blob is not bigger than the initial-blob-size + replaceBufferSize
        // then the existing memory-address can be used, else new memory address would be allocated and old memory-address freed.
        replaceBufferSize:Nat64;
    };
};