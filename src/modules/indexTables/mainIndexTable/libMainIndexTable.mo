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

    public class libMainIndexTable(
        memoryStorageToUse : MemoryStorageTypes.MemoryStorage,
        tableIndexMaxEntriesToUse : Nat64,
    ) {

        private let memoryStorage : MemoryStorageTypes.MemoryStorage = memoryStorageToUse;
        //private let offsets_IndexTableHeader = CommonTypes.Offsets_IndexTableHeader;
        private let offset = CommonTypes.Offset_IndexTable;
        private let tableIndexMaxEntries : Nat64 = tableIndexMaxEntriesToUse;

        public func get_items_count(mainIndexTableAddress : Nat64) : Nat64 {
            Region.loadNat64(memoryStorage.memory_region.region, mainIndexTableAddress + offset.entriesCount);
        };

        public func set_items_count(mainIndexTableAddress : Nat64, newCountValue : Nat64) {
            Region.storeNat64(
                memoryStorage.memory_region.region,
                mainIndexTableAddress + offset.entriesCount,
                newCountValue,
            );
        };

        public func set_parent_table_address(mainIndexTableAddress : Nat64, parentTableAddress : Nat64) {
            Region.storeNat64(
                memoryStorage.memory_region.region,
                mainIndexTableAddress + offset.parentTable,
                parentTableAddress,
            );
        };

        public func set_parent_table_used_index(mainIndexTableAddress : Nat64, parentTableIndex : Nat64) {
            Region.storeNat64(
                memoryStorage.memory_region.region,
                mainIndexTableAddress + offset.parentTableIndex,
                parentTableIndex,
            );
        };

        public func set_next_table_address(mainIndexTableAddress : Nat64, nextTableAddress : Nat64) {
            Region.storeNat64(
                memoryStorage.memory_region.region,
                mainIndexTableAddress + offset.nextIndexTable,
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
        public func append_item(indexTableAddress:Nat64, wrappedBlobAddress:Nat64 ){
            
            let region = memoryStorage.memory_region.region;
            let currentCount = get_items_count(indexTableAddress);
            let memoryPosition:Nat64 = offset.minSize + currentCount * 8;

            Region.storeNat64(region, indexTableAddress + memoryPosition, wrappedBlobAddress);
            set_items_count(indexTableAddress, currentCount + 1);
           
        };

        // create empty main-index-table and store into memory
        public func create_new() : Nat64 {
            let region = memoryStorage.memory_region.region;

            let sizeNeeded : Nat64 = offset.minSize + tableIndexMaxEntries * 8;
            let address = MemoryRegion.allocate(
                memoryStorage.memory_region,
                Nat64.toNat(offset.minSize),
            );
            let addressNat64 : Nat64 = Nat64.fromNat(address);

            // let addressOfPreviousTable:Nat64 = Option.get<Nat64>(prevTableAddress,0);
            // let addressOfNextTable:Nat64 = Option.get<Nat64>(nextTableAddress, 0);
            // let addressOfParentTable:Nat64 = Option.get<Nat64>(parentTableAddress,0);
            // let indexInsideParentTable:Nat64 = Option.get<Nat64>(parentTableIndex, 0);

            // set identifier
            Region.storeNat64(
                region,
                addressNat64 + offset.identifier,
                CommonTypes.identifier_MainIndexTable,
            );

            // entries count
            Region.storeNat64(region, addressNat64 + offset.entriesCount, 0);

            // sum of all items count. (here it is always the same number as entries count,
            // because it is maintable. And therefore we can let this value be always 0)
            Region.storeNat64(region, addressNat64 + offset.sumOfItemsCount, 0);


            // set parent table-addresses
            Region.storeNat64(region, addressNat64 + offset.parentTable, 0);
            Region.storeNat64(region, addressNat64 + offset.parentTableIndex, 0);

            // set next and previous main-index-table address
            Region.storeNat64(region, addressNat64 + offset.nextIndexTable, 0);
            Region.storeNat64(region, addressNat64 + offset.previousIndexTable, 0);

            // // Set the wrapped-blob address (at index location 0)
            // Region.storeNat64(region, addressNat64 + offset.minSize, 0);

            return addressNat64;
        };

    };

};
