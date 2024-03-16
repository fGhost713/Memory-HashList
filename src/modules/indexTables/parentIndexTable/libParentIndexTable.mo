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

    public class libParentIndexTable(
        memoryStorageToUse : MemoryStorageTypes.MemoryStorage,
        tableIndexMaxEntriesToUse : Nat64,
    ) {

        private let memoryStorage : MemoryStorageTypes.MemoryStorage = memoryStorageToUse;
        //private let offsets_IndexTableHeader = CommonTypes.Offsets_IndexTableHeader;
        private let offset = CommonTypes.Offset_IndexTable;
        private let tableIndexMaxEntries : Nat64 = tableIndexMaxEntriesToUse;

        public func get_items_count(parentIndexTableAddress:Nat64):Nat64{
            Region.loadNat64(memoryStorage.memory_region.region,parentIndexTableAddress + offset.entriesCount);
        };

        public func set_items_count(memoryAddress : Nat64, newCountValue : Nat64) {
            Region.storeNat64(
                memoryStorage.memory_region.region,
                memoryAddress + offset.entriesCount,
                newCountValue,
            );
        };

         public func get_sum_of_all_items_count(parentIndexTableAddress:Nat64):Nat64{
            Region.loadNat64(memoryStorage.memory_region.region,parentIndexTableAddress + offset.sumOfItemsCount);
        };

        public func set_sum_of_all_items_count(memoryAddress : Nat64, sumCountOfAllItemsCountInThisTable : Nat64) {
            Region.storeNat64(
                memoryStorage.memory_region.region,
                memoryAddress + offset.sumOfItemsCount,
                sumCountOfAllItemsCountInThisTable,
            );
        };

        public func set_parent_table_address(memoryAddress : Nat64, parentTableAddress : Nat64) {
            Region.storeNat64(
                memoryStorage.memory_region.region,
                memoryAddress + offset.parentTable,
                parentTableAddress,
            );
        };

        public func set_parent_table_used_index(memoryAddress : Nat64, parentTableIndex : Nat64) {
            Region.storeNat64(
                memoryStorage.memory_region.region,
                memoryAddress + offset.parentTableIndex,
                parentTableIndex,
            );
        };

        public func set_next_table_address(memoryAddress : Nat64, nextTableAddress : Nat64) {
            Region.storeNat64(
                memoryStorage.memory_region.region,
                memoryAddress + offset.nextIndexTable,
                nextTableAddress,
            );
        };

        public func set_previous_table_address(mainIndexTableAddress : Nat64, previousTableAddress : Nat64) {
            Region.storeNat64(
                memoryStorage.memory_region.region,
                mainIndexTableAddress + offset.previousIndexTable,
                previousTableAddress,
            );
        };

        // Here no check is taking place. We should only call this method when we are sure
        // that the item fit in the corresponding initial allocated memory size.  
        public func append_item(indexTableAddress:Nat64, itemCount:Nat64, itemAddress:Nat64 ){
            
            let region = memoryStorage.memory_region.region;
            let currentCount = get_items_count(indexTableAddress);
            let memoryPosition:Nat64 = offset.minSize + currentCount * 2 * 8;

            Region.storeNat64(region, indexTableAddress + memoryPosition, itemCount);
            Region.storeNat64(region, indexTableAddress + memoryPosition + 1 , itemAddress);

            set_items_count(indexTableAddress, currentCount + 1);
            let sumOfAllItemsCount = get_sum_of_all_items_count(indexTableAddress);
            set_sum_of_all_items_count(indexTableAddress, sumOfAllItemsCount + itemCount);

        };

        // Create new empty parent-index-table
        public func create_new():Nat64 {
            let region = memoryStorage.memory_region.region;

            let sizeNeeded:Nat64 = offset.minSize + tableIndexMaxEntries * 2 * 8;
            let address = MemoryRegion.allocate(
                memoryStorage.memory_region,
                Nat64.toNat(offset.minSize)
            );
            let addressNat64:Nat64 = Nat64.fromNat(address); 

            // set identifier
            Region.storeNat64(
                region,
                addressNat64 + offset.identifier,
                CommonTypes.identifier_ParentIndexTable
            );

            // entries count
            Region.storeNat64(region,addressNat64 + offset.entriesCount ,0 );

            // sum of all items count. 
            Region.storeNat64(region, addressNat64 + offset.sumOfItemsCount, 0);

            // set parent table-addresses
            Region.storeNat64(region,addressNat64 + offset.parentTable ,0 );
            Region.storeNat64(region,addressNat64 + offset.parentTableIndex ,0 );

            // set next and previous main-index-table address
            Region.storeNat64(region,addressNat64 + offset.nextIndexTable ,0 );
            Region.storeNat64(region,addressNat64 + offset.previousIndexTable ,0 );

            // // Set the wrapped-blob address (at index location 0)
            // Region.storeNat64(region,addressNat64 + offset.minSize,wrappedBlobAddress);

            return addressNat64;
        };

    };

};
