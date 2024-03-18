import Blob "mo:base/Blob";
import HashListTypes "../../../types/hashListTypes";
import StableTrieMap "mo:StableTrieMap";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Region "mo:base/Region";
import Iter "mo:base/Iter";
import List "mo:base/List";
import Binary "../../../helpers/binary";
import Itertools "mo:itertools/Iter";
import Option "mo:base/Option";
import Debug "mo:base/Debug";
import Nat8 "mo:base/Nat8";
import { MemoryRegion } "mo:memory-region";
import GlobalFunctions "../../../helpers/globalFunctions";
import CommonTypes "../../../types/commonTypes";
import Prim "mo:⛔";
import MemoryStorageTypes "../../../types/memoryStorage/memoryStorageTypes";

module {

    public class libTableHeader(
        memoryStorageToUse : MemoryStorageTypes.MemoryStorage,
        tableIndexMaxEntriesToUse : Nat64,
    ) {
        private let memoryStorage : MemoryStorageTypes.MemoryStorage = memoryStorageToUse;
        private let offset = CommonTypes.Offsets_IndexTableHeader;
        private let tableIndexMaxEntries : Nat64 = tableIndexMaxEntriesToUse;


        public func get_last_stored_wrapped_blob_address(mainIndexTableAddress : Nat64):Nat64{
            Region.loadNat64(
                memoryStorage.memory_region.region, 
                mainIndexTableAddress + offset.addressOfLastWrappedBlob
            );
        };

          public func set_last_stored_wrapped_blob_address(mainIndexTableAddress : Nat64,
           lastUsedWrappedBlobAddress:Nat64){
            Region.storeNat64(
                memoryStorage.memory_region.region, 
                mainIndexTableAddress + offset.addressOfLastWrappedBlob,
                lastUsedWrappedBlobAddress
            );
        };

        public func get_total_items_count(memoryAddress:Nat64):Nat64{
            Region.loadNat64(memoryStorage.memory_region.region, memoryAddress + offset.totalEntriesCount);
        };

        public func set_total_items_count(memoryAddress:Nat64, newCount:Nat64){
           
            Region.storeNat64(
                memoryStorage.memory_region.region,
                memoryAddress + offset.totalEntriesCount,
                newCount
            );
        };

        public func get_end_main_index_table(indexHeaderTable:Nat64):Nat64{
            Region.loadNat64(
                memoryStorage.memory_region.region, 
                indexHeaderTable + offset.endMainIndexTable);
        };

        public func create_new(mainIndexTableAddress : Nat64, parentIndexTableAddress:Nat64,
        wrappedBlobAddress : Nat64, entriesCount:Nat64
        
        ) : Nat64 {

            let region = memoryStorage.memory_region.region;
            let table_header_address = MemoryRegion.allocate(
                memoryStorage.memory_region,
                Nat64.toNat(offset.bytesNeeded),
            );
            let table_header_addressNat64 : Nat64 = Nat64.fromNat(table_header_address);

            // set identifier
            Region.storeNat64(
                region,
                table_header_addressNat64 + offset.identifier,
                CommonTypes.identifier_IndexTableHeader,
            );

            // set entries count:
            Region.storeNat64(
                region,
                table_header_addressNat64 + offset.totalEntriesCount,
                entriesCount,
            );

            // set address of first wrapped-blob
            Region.storeNat64(
                region,
                table_header_addressNat64 + offset.addressOfFirstWrappedBlob,
                wrappedBlobAddress,
            );
            // set address of last wrapped-blob:
            Region.storeNat64(
                region,
                table_header_addressNat64 + offset.addressOfLastWrappedBlob,
                wrappedBlobAddress,
            );

            // set memory address of first main-index-table
            Region.storeNat64(
                region,
                table_header_addressNat64 + offset.startMainIndexTable,
                mainIndexTableAddress,
            );

            // set memory address of last main-index-table
            Region.storeNat64(
                region,
                table_header_addressNat64 + offset.endMainIndexTable,
                mainIndexTableAddress,
            );

            // set memory locations for all parent index-tables to 0
            // (because the parent index-tables not exist, yet)
            Region.storeNat64(
                region,
                table_header_addressNat64 + offset.startFirstParentIndexTable,
                parentIndexTableAddress,
            );

            Region.storeNat64(
                region,
                table_header_addressNat64 + offset.endFirstParentIndexTable,
                parentIndexTableAddress,
            );

            Region.storeNat64(
                region,
                table_header_addressNat64 + offset.startLastParentIndexTable,
                parentIndexTableAddress,
            );

            Region.storeNat64(
                region,
                table_header_addressNat64 + offset.endLastParentIndexTable,
                parentIndexTableAddress,
            );

            return table_header_addressNat64;

        };

    };

};
