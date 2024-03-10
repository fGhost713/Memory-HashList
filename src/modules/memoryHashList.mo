import HashListTypes "../types/hashListTypes";
import LibKeyInfo "libKeyInfo";
import LibWrappedBlob "libWrappedBlob";
import Option "mo:base/Option";
import Result "mo:base/Result";
import BlobifyModule "mo:memory-buffer/Blobify";
import { MemoryRegion } "mo:memory-region";
import StableTrieMap "mo:StableTrieMap";
import GlobalFunctions "../helpers/globalFunctions";
import KeyOperator "keyOperator";
 
module {

    public type MemoryStorage = HashListTypes.MemoryStorage;
    //private type KeyInfo = HashListTypes.KeyInfo;
    //private type WrappedBlob = HashListTypes.WrappedBlob;

    public class MemoryHashList(memoryStorageToUse : MemoryStorage) {
        private let memoryStorage : MemoryStorage = memoryStorageToUse;
        private let keyOperator = KeyOperator(memoryStorageToUse);

        private var blobHashFunction = GlobalFunctions.blobHash;
        private var nat32IdentityFunction = GlobalFunctions.nat32Identity;

        // This function is useful for tests, so that we can define the 
        // blob-to-hash function. With this we can forcefully simulate hash collisions in the tests later.
        public func setBlobHashingFunction(blobHash:Blob->Nat32){
            blobHashFunction:=blobHash;
        };

        // Add or update value by key
        public func put(key : Blob, value : Blob)  {
            var hashedKey : Nat32 =  blobHashFunction(key);

            // Get current values for the key
            var memoryAddresses:List.List<Nate64> = keyOperator.get_values(hashedKey);

            if (List.size(memoryAddresses) == 0){ //Key not exist
                

            } else{


            };

            //return LibWrappedBlob.add_or_update(key, memoryStorage, value);
        };
        // // Add or update value by key
        // public func put(key : Blob, value : Blob) : Nat64 {
        //     return LibWrappedBlob.add_or_update(key, memoryStorage, value);
        // };

        // // Get value (as blob) by key
        // public func get(key : Blob) : ?Blob {
        //     let keyInfo : (?KeyInfo, Nat64 /*address of keyinfo*/) = LibKeyInfo.get_keyinfo(key, memoryStorage);

        //     let keyInfoOrNull = keyInfo.0;
        //     switch (keyInfoOrNull) {
        //         case (?keyinfo) {
        //             let internalBlob:Blob = LibWrappedBlob.get_internal_blob_from_memory( memoryStorage,
        //                 keyinfo.wrappedBlobAddress);
        //             return Option.make(internalBlob);
        //         };
        //         case (_) {
        //             return null;
        //         };
        //     };
        // };

        // // Delete value by key
        // public func delete(key : Blob) {
        //     LibWrappedBlob.delete(key, memoryStorage);         
        // };

    };

};
