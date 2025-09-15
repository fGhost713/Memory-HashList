import List "mo:base/List";
import Nat64 "mo:base/Nat64";
import Nat32 "mo:base/Nat32";
import BlobifyModule "/helpers/blobify";
import { MemoryRegion } "mo:memory-region";
import StableTrieMap "mo:StableTrieMap";
import MemoryHashListModule "/modules/libMemoryHashList";
import MemoryStorageTypes "types/memoryStorage/memoryStorageTypes";
import StableMemoryHashListModule "/modules/libStableMemoryHashList";
import Vector "mo:vector";

module {

    // the memoryStorage (should be stored as stable in your code)
    public type MemoryStorage = MemoryStorageTypes.MemoryStorage;

    // helper for conversion from/to blob
    public let Blobify = BlobifyModule;

    // Memory HashList for class usage
    public let MemoryHashList = MemoryHashListModule.libMemoryHashList;

    // Memory HashList for static (stable) usage
    public let StableMemoryHashList = StableMemoryHashListModule;

    public func get_new_memory_storage(replaceBufferSizeInBytes : Nat) : MemoryStorage {

        let newItem : MemoryStorage = {
            memory_region : MemoryRegion.MemoryRegion = MemoryRegion.new();
            var memory_used_firstAddress : ?Nat64 = null;
            var memory_used_lastAddress : Nat64 = 0;
            keyToKeyInfoAddressMappings : StableTrieMap.StableTrieMap<Nat32, List.List<Nat64>> = StableTrieMap.new();
            indizesPerKey : Vector.Vector<Vector.Vector<Nat64>> = Vector.new();
            indizesPerKey_free : Vector.Vector<Nat> = Vector.new();
            replaceBufferSize : Nat32 = Nat32.fromNat(replaceBufferSizeInBytes);

        };
        return newItem;
    };
};
