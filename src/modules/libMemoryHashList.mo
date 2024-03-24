import Result "mo:base/Result";
import Nat64 "mo:base/Nat64";
import Nat "mo:base/Nat";
import MemoryStorageTypes "../types/memoryStorage/memoryStorageTypes";
import StableMemoryHashList "libStableMemoryHashList";

module {

    public class libMemoryHashList(memoryStorageToUse : MemoryStorageTypes.MemoryStorage) {

        private let memoryStorage : MemoryStorageTypes.MemoryStorage = memoryStorageToUse;
        private type MemoryStorage = MemoryStorageTypes.MemoryStorage;

        public func add_many(key : Blob, values : [Blob]) {
            StableMemoryHashList.add_many(memoryStorage, key, values);
        };

        // adding new value for specified key (if key is not existing it is created)
        public func add(key : Blob, value : Blob) : (Nat /*index*/, Nat64 /* wrapped-blob address*/) {
            StableMemoryHashList.add(memoryStorage, key, value);
        };

        // Returns all the used keys (as blob)
        public func get_all_keys() : [Blob] {
            StableMemoryHashList.get_all_keys(memoryStorage);
        };

        // Overwrites the existing blob at specified index
        public func update_at_index(key : Blob, index : Nat, newBlob : Blob) : Result.Result<Text, Text> {
            StableMemoryHashList.update_at_index(memoryStorage : MemoryStorage, key : Blob, index : Nat, newBlob : Blob);
        };

        public func insert_many_at_index(key : Blob, index : Nat, blobs : [Blob]) : Result.Result<Text, Text> {
            StableMemoryHashList.insert_many_at_index(memoryStorage : MemoryStorage, key : Blob, index : Nat, blobs : [Blob]);
        };

        // Insert blob-value at index
        public func insert_at_index(key : Blob, index : Nat, newBlob : Blob) : Result.Result<Nat64, Text> {

            StableMemoryHashList.insert_at_index(memoryStorage : MemoryStorage, key : Blob, index : Nat, newBlob : Blob);
        };

        // Removes values for the key from 'firstIndex' to 'lastIndex'
        public func remove_at_range(key : Blob, startIndex : Nat, lastIndexOrNull : ?Nat) : Result.Result<Text, Text> {

            StableMemoryHashList.remove_at_range(memoryStorage : MemoryStorage, key : Blob, startIndex : Nat, lastIndexOrNull : ?Nat);

        };

        // Removes value for the key at specific index position
        public func remove_at_index(key : Blob, index : Nat) : Result.Result<Text, Text> {

            StableMemoryHashList.remove_at_index(memoryStorage : MemoryStorage, key : Blob, index : Nat);

        };

        // removes the key and all the added values to this key
        public func remove_key(key : Blob) {

            StableMemoryHashList.remove_key(memoryStorage : MemoryStorage, key : Blob);

        };

        public func get_at_index(key : Blob, innerIndex : Nat) : ?Blob {

            StableMemoryHashList.get_at_index(memoryStorage : MemoryStorage, key : Blob, innerIndex : Nat);

        };

        public func get_at_range(key : Blob, firstIndex : Nat, lastIndex : Nat) : [Blob] {

            StableMemoryHashList.get_at_range(memoryStorage : MemoryStorage, key : Blob, firstIndex : Nat, lastIndex : Nat);

        };

        // return last index or null if empty
        public func get_last_index(key : Blob) : ?Nat {
            StableMemoryHashList.get_last_index(memoryStorage : MemoryStorage, key : Blob);

        };
    };
};
