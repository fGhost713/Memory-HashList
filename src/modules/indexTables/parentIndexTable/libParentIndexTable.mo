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
import TableUpdateInfoTypes "../../../types/indexTable/tableUpdateInfoTypes";

module {

    public class libParentIndexTable(
        memoryStorageToUse : MemoryStorageTypes.MemoryStorage,
        tableIndexMaxEntriesToUse : Nat64,
    ) {

        private let memoryStorage : MemoryStorageTypes.MemoryStorage = memoryStorageToUse;
        //private let offsets_IndexTableHeader = CommonTypes.Offsets_IndexTableHeader;
        private let offset = CommonTypes.Offset_IndexTable;
        private let tableIndexMaxEntries : Nat64 = tableIndexMaxEntriesToUse;
        private type TableUpdateInfo = TableUpdateInfoTypes.TableUpdateInfo;
        public func get_entries_count(parentIndexTableAddress:Nat64):Nat64{
            Region.loadNat64(memoryStorage.memory_region.region,parentIndexTableAddress + offset.entriesCount);
        };

        private func set_entries_count(memoryAddress : Nat64, newCountValue : Nat64) {
            Region.storeNat64(
                memoryStorage.memory_region.region,
                memoryAddress + offset.entriesCount,
                newCountValue,
            );
        };

         public func get_sum_of_all_items_count(parentIndexTableAddress:Nat64):Nat64{
            Region.loadNat64(memoryStorage.memory_region.region,parentIndexTableAddress + offset.sumOfItemsCount);
        };

        private func set_sum_of_all_items_count(memoryAddress : Nat64, sumCountOfAllItemsCountInThisTable : Nat64) {
            Region.storeNat64(
                memoryStorage.memory_region.region,
                memoryAddress + offset.sumOfItemsCount,
                sumCountOfAllItemsCountInThisTable,
            );
        };

        public func get_parent_table_address(memoryAddress : Nat64):Nat64 {
          
            Region.loadNat64(
                memoryStorage.memory_region.region,
                memoryAddress + offset.parentTable
            );
        };

        private func set_parent_table_address(memoryAddress : Nat64, parentTableAddress : Nat64) {
            Region.storeNat64(
                memoryStorage.memory_region.region,
                memoryAddress + offset.parentTable,
                parentTableAddress,
            );
        };

        private func set_parent_table_used_index(memoryAddress : Nat64, parentTableIndex : Nat64) {
            Region.storeNat64(
                memoryStorage.memory_region.region,
                memoryAddress + offset.parentTableIndex,
                parentTableIndex,
            );
        };

        private func set_next_table_address(memoryAddress : Nat64, nextTableAddress : Nat64) {
            Region.storeNat64(
                memoryStorage.memory_region.region,
                memoryAddress + offset.nextIndexTable,
                nextTableAddress,
            );
        };

        private func set_previous_table_address(mainIndexTableAddress : Nat64, previousTableAddress : Nat64) {
            Region.storeNat64(
                memoryStorage.memory_region.region,
                mainIndexTableAddress + offset.previousIndexTable,
                previousTableAddress,
            );
        };

        // Here no check is taking place. We should only call this method when we are sure
        // that the item fit in the corresponding initial allocated memory size.  
        private func append_item_internal(indexTableAddress:Nat64, prevTableAddress:Nat64,
         isNewCreatedTable:Bool,

        newEntryItemsCount:Nat64, itemAddress:Nat64 )
        :TableUpdateInfo{
            
            let region = memoryStorage.memory_region.region;
            let currentCount = get_entries_count(indexTableAddress);
            let memoryPosition:Nat64 = offset.minSize + currentCount * 2 * 8;

            Region.storeNat64(region, indexTableAddress + memoryPosition, newEntryItemsCount);
            Region.storeNat64(region, indexTableAddress + memoryPosition + 1 , itemAddress);

            set_entries_count(indexTableAddress, currentCount + 1);
            let sumOfAllTheItemsCount = get_sum_of_all_items_count(indexTableAddress);
            set_sum_of_all_items_count(indexTableAddress, sumOfAllTheItemsCount + newEntryItemsCount);

            let newResultEntry:TableUpdateInfo = {
                            isNewTable:Bool = isNewCreatedTable;
                            ownAddress:Nat64 = indexTableAddress;
                            prevTableAddress:Nat64 = prevTableAddress;
                            sumOfAllItemsCount:Nat64 = sumOfAllTheItemsCount + newEntryItemsCount;
                            usedIndex:Nat64 = currentCount;
            };
            return newResultEntry;
        };

        public func update_tables_count_by_1(parentTableAddress:Nat64,parentTableIndex:Nat64){

            let region = memoryStorage.memory_region.region;
            var finished = false;
            var currentTable:Nat64 = parentTableAddress;
            var currentIndex:Nat64 = parentTableIndex;

            while(finished == false){
                let memoryPosition:Nat64 = offset.minSize + currentIndex * 2 * 8;
                
                let itemsCountOnIndex:Nat64 = Region.loadNat64(region, currentTable + memoryPosition);
                Region.storeNat64(region, currentTable + memoryPosition, itemsCountOnIndex + 1);

                let sumOfAll:Nat64 = Region.loadNat64(region, currentTable + offset.sumOfItemsCount);
                Region.storeNat64(region, currentTable + offset.sumOfItemsCount, sumOfAll + 1);

                let upperTable =get_parent_table_address(currentTable);
                if (upperTable == 0 or upperTable == currentTable){
                    finished:=true;
                } else{
                    currentTable := upperTable;
                    
                };

            };

        };

        public func append_item2(parentTableAddress:Nat64,totalItemsInTableCount:Nat64, mainIndexTableAddress:Nat64){
            //let upper_parentTable:(Bool, Nat64) = get_parent_table_address(parentTableAddress);

            var finished = false;
            var currentTable:Nat64 = parentTableAddress;
            let region = memoryStorage.memory_region.region;

            var sumOfAllItemsCount = totalItemsInTableCount;
            var value = mainIndexTableAddress;
            var returnResult:List.List<TableUpdateInfo> = List.nil<TableUpdateInfo>();
        
            while(finished == false){
                //let currentTotalCount = get_sum_of_all_items_count(currentTable);
                let currentEntriesCount = get_entries_count(currentTable);
                if (currentEntriesCount < tableIndexMaxEntries){

                    // // Add new entry + update entries-count and sum-of-all-items-count
                    // let memoryPosition:Nat64 = offset.minSize + currentEntriesCount * 2 * 8;
                    // Region.storeNat64(region, currentTable + memoryPosition, sumOfAllItemsCount);
                    // Region.storeNat64(region, currentTable + memoryPosition + 1 , value);

                    // set_entries_count(currentTable, currentEntriesCount + 1);
                    // let currentSumOfAllItemsCount = get_sum_of_all_items_count(currentTable);
                    // set_sum_of_all_items_count(currentTable, currentSumOfAllItemsCount + sumOfAllItemsCount);

                    // let newResultEntry:TableUpdateInfo = {
                    //         isNewTable:Bool = false;
                    //         ownAddress:Nat64 = currentTable;
                    //         sumOfAllItemsCount:Nat64 = currentSumOfAllItemsCount + sumOfAllItemsCount;
                    //         usedIndex:Nat64 = currentEntriesCount;
                    // };
                    let newResultEntry = append_item_internal(currentTable,currentTable,false,sumOfAllItemsCount,value);
                    returnResult := List.push(newResultEntry, returnResult);

                } else { // we need to create new table
                    let newParentTable = create_new();
                };

                let getParentTableResponse = get_parent_table_address(currentTable);
                if (getParentTableResponse.0 == false){
                    finished:=true;
                };


            };
            //let entriesCount = 



        };



        // Create new empty parent-index-table
        public func create_new(prevIndexTable:?Nat64):Nat64 {
            let region = memoryStorage.memory_region.region;

            let sizeNeeded:Nat64 = offset.minSize + tableIndexMaxEntries * 2 * 8;
            let address = MemoryRegion.allocate(
                memoryStorage.memory_region,
                Nat64.toNat(offset.minSize)
            );
            let addressNat64:Nat64 = Nat64.fromNat(address); 

            let previousTableIndex:Nat64 = Option.get<Nat64>(prevIndexTable,0);
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
