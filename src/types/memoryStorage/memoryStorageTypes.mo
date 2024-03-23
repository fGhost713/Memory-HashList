import { MemoryRegion } "mo:memory-region";
import StableTrieMap "mo:StableTrieMap";
import List "mo:base/List";
import Nat64 "mo:base/Nat64";
import Vector "mo:vector";

module {

    public type MemoryStorage = {

        // The used memory region
        memory_region : MemoryRegion.MemoryRegion;

        // first allocated memory position
        var memory_used_firstAddress : ?Nat64;

        // last allocated memory position
        var memory_used_lastAddress : Nat64;

        // The memory-addresses for the corresponding keyinfo
        // There might be more indizies in case of hash-collision (== same Nat32 hashed key) therefore the value as List.
        keyToKeyInfoAddressMappings : StableTrieMap.StableTrieMap<Nat32, List.List<Nat64>>;

        // indizes per key
        indizesPerKey : Vector.Vector<Vector.Vector<Nat64>>;

        // free indizes are stored here
        indizesPerKey_free : Vector.Vector<Nat>;

        // The replace buffer size
        // If value update method is called and the new blob is not bigger than the initial-blob-size + replaceBufferSize
        // then the existing memory-address can be used, else new memory address would be allocated and old memory-address freed.
        replaceBufferSize : Nat64;

    };
};
