import HashListTypes "../types/hashListTypes";
import LibKeyInfo "libKeyInfo";
import LibWrappedBlob "libWrappedBlob";
import LibKey "libKey";
import Option "mo:base/Option";
import Result "mo:base/Result";
import List "mo:base/List";
import Nat64 "mo:base/Nat64";
import BlobifyModule "mo:memory-buffer/Blobify";
import { MemoryRegion } "mo:memory-region";
import StableTrieMap "mo:StableTrieMap";
import GlobalFunctions "../helpers/globalFunctions";
import MemoryStorageTypes "../types/memoryStorage/memoryStorageTypes";
import LibIndexTables "indexTables/libIndexTables";
import CommonTypes "../types/commonTypes";
import ResponseResultTypes "../types/response/responseResultTypes";

module {

    //private type KeyInfo = HashListTypes.KeyInfo;
    //private type WrappedBlob = HashListTypes.WrappedBlob;

    public class MemoryHashList(memoryStorageToUse : MemoryStorageTypes.MemoryStorage, tableIndexMaxEntries:Nat64) {
        private let memoryStorage : MemoryStorageTypes.MemoryStorage = memoryStorageToUse;
        
        private let libKey = LibKey.libKey(memoryStorageToUse);
        private let libWrappedBlob = LibWrappedBlob.libWrappedBlob(memoryStorageToUse);
        private let libKeyInfo = LibKeyInfo.libKeyInfo(memoryStorageToUse);
        private let libIndexTables = LibIndexTables.libIndexTables(memoryStorageToUse, tableIndexMaxEntries);

        private var blobHashFunction = GlobalFunctions.blobHash;
        private var nat32IdentityFunction = GlobalFunctions.nat32Identity;

        private type ResponseResult = CommonTypes.ResponseResult;

        // This function is useful for tests, so that we can define the 
        // blob-to-hash function. With this we can forcefully simulate hash collisions in the tests later.
        public func setBlobHashingFunction(blobHash:Blob->Nat32){
            blobHashFunction:=blobHash;
        };

        
        // Append new value for specific key
        public func append(key : Blob, value : Blob):Result.Result<ResponseResult, Text>{
            var hashedKey : Nat32 =  blobHashFunction(key);

            // Get current values for the key
            var memoryAddresses:List.List<Nat64> = libKey.get_values(hashedKey);
            var keyInfoWasFound:Bool = false;
            var keyInfoAddress:Nat64 = 0;

            // store the blob:
            let wrappedBlobMemoryAddress = libWrappedBlob.create_new(value, null,null);

            if (List.size(memoryAddresses) > 0){
                let getKeyInfoAddressResult: (Bool /*found*/, Nat64 /*address*/) = libKeyInfo.get_correct_keyinfo_address(key,memoryAddresses);
                keyInfoWasFound:= getKeyInfoAddressResult.0;
                keyInfoAddress:= getKeyInfoAddressResult.1;
            };

            if (List.size(memoryAddresses) == 0 or keyInfoWasFound == false){ //Key not exist  
                // create parent-index-table
                let parent_index_table = libIndexTables.parentIndexTable.create_new();

                // create new main-index-table
                let main_index_table_address = libIndexTables.mainIndexTable.create_new();

                // create new index-table-header
                let table_header_address = libIndexTables.tableHeader.create_new(
                    main_index_table_address,
                    parent_index_table,
                    wrappedBlobMemoryAddress,
                    1
                );

                // update the tables
                libIndexTables.parentIndexTable.append_item(parent_index_table,1, main_index_table_address);
                libIndexTables.mainIndexTable.append_item(main_index_table_address,wrappedBlobMemoryAddress);
                libIndexTables.mainIndexTable.set_parent_table_address(main_index_table_address, parent_index_table);
                libIndexTables.mainIndexTable.set_parent_table_used_index(main_index_table_address, 0);

                // create corresponding key-info
                keyInfoAddress := libKeyInfo.create_new(key, table_header_address);
                
                // Push libKeyInfo-Address as value for the specified key 
                libKey.add_entry(hashedKey,keyInfoAddress);

                let result:ResponseResultTypes.ResponseResult = {
                    wrappedItemExist = true;
                    memoryAddress_wrappedBlob:Nat64 = wrappedBlobMemoryAddress;
                    memoryAddress_indexTableHeader:Nat64 = table_header_address;
                    blob:?Blob = Option.make(value);
                };
                return #ok(result);

            } else{
                
                let indexTableHeader_address = libKeyInfo.get_address_of_index_table_header(keyInfoAddress);
                
                let lastStoredWrappedBlobAddress = libIndexTables.tableHeader.get_last_stored_wrapped_blob_address(indexTableHeader_address);

                // store the blob:
                let wrappedBlobMemoryAddress = libWrappedBlob.create_new(
                    value, 
                    Option.make(lastStoredWrappedBlobAddress),null
                );

                let currentItemsCountInWrappedBlob = libIndexTables.mainIndexTable.get_items_count();

                // Update next-address of previous wrapped-blob
                libWrappedBlob.update_next_blob_address_value(lastStoredWrappedBlobAddress, wrappedBlobMemoryAddress);


                //let newCount = libIndexTables.tableHeader.items_count_increase(indexTableHeader_address,1);
                // // Update next-address value for the previous wrapped-blob
                // libWrappedBlob.update_next_blob_address_value(lastStoredWrappedBlobAddress,newLastWrappedBlobMemoryAddress);

                // // Update last wrapped-blob adress in keyinfo
                // libKeyInfo.update_last_wrappedblob_address(keyInfoAddress,newLastWrappedBlobMemoryAddress);

                // let tableAddresses = libKeyInfo.get_last_tableAddresses(keyInfoAddress);
           
                // // Add new entry in index-tables
                // let newTableAddresses = libBucketIndexer.append_new_wrapped_blob_address(
                //     newLastWrappedBlobMemoryAddress,
                //     tableAddresses.0,
                //     tableAddresses.1,
                //     tableAddresses.2
                // );

                // libKeyInfo.update_last_tableAddresses(
                //     keyInfoAddress, 
                //     newTableAddresses.0,
                //     newTableAddresses.1,
                //     newTableAddresses.2
                // );

                // libKeyInfo.total_items_count_increase(keyInfoAddress, 1);

                return #ok("Value for existing key was added.");

            };
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
