import List "mo:base/List";
import Nat64 "mo:base/Nat64";
import BlobifyModule "mo:memory-buffer/Blobify";
import { MemoryRegion } "mo:memory-region";
import StableTrieMap "mo:StableTrieMap";
import MemoryHashListModule "/modules/libMemoryHashList";
import MemoryStorageTypes "types/memoryStorage/memoryStorageTypes";
import Vector "mo:vector";

module {
	
	public type MemoryStorage = MemoryStorageTypes.MemoryStorage;
	public let Blobify = BlobifyModule;
	public let MemoryHashList = MemoryHashListModule.libMemoryHashList;

	public func get_new_memory_storage(replaceBufferSizeInBytes:Nat) : MemoryStorage {

        let newItem : MemoryStorage = {
            memory_region: MemoryRegion.MemoryRegion = MemoryRegion.new();
            var memory_used_firstAddress:?Nat64 = null;
            var memory_used_lastAddress:Nat64 = 0;
            keyToKeyInfoAddressMappings: StableTrieMap.StableTrieMap<Nat32, List.List<Nat64>> = StableTrieMap.new();
            indizesPerKey:Vector.Vector<Vector.Vector<Nat64>> = Vector.new(); 
            indizesPerKey_free:Vector.Vector<Nat> = Vector.new();
            replaceBufferSize:Nat64 = Nat64.fromNat(replaceBufferSizeInBytes);
      
        };
        return newItem;
    };
};