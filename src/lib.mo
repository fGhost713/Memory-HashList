import LibKeyInfo "modules/libKeyInfo";
import LibWrappedBlob "modules/libWrappedBlob";
import Option "mo:base/Option";
import Blob "mo:base/Blob";
import Nat8 "mo:base/Nat8";
import List "mo:base/List";
import Iter "mo:base/Iter";
import Nat64 "mo:base/Nat64";
import Debug "mo:base/Debug";
import Array "mo:base/Array";
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
            keyToKeyInfoAddressMappings: StableTrieMap.StableTrieMap<Nat32, List.List<Nat64>> = StableTrieMap.new();
            indizesPerKey:Vector.Vector<Vector.Vector<Nat64>> = Vector.new(); 
            indizesPerKey_free:Vector.Vector<Nat> = Vector.new();
            replaceBufferSize:Nat64 = Nat64.fromNat(replaceBufferSizeInBytes);
      
        };
        return newItem;
    };
};