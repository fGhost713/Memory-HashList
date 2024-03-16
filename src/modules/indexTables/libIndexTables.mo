import Blob "mo:base/Blob";
import HashListTypes "../../types/hashListTypes";
import StableTrieMap "mo:StableTrieMap";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Region "mo:base/Region";
import Iter "mo:base/Iter";
import List "mo:base/List";
import Binary "../../helpers/binary";
import Itertools "mo:itertools/Iter";
import Option "mo:base/Option";
import Debug "mo:base/Debug";
import Nat8 "mo:base/Nat8";
import { MemoryRegion } "mo:memory-region";
import GlobalFunctions "../../helpers/globalFunctions";
import CommonTypes "../../types/commonTypes";
import Prim "mo:⛔";
import MemoryStorageTypes "../..//types/memoryStorage/memoryStorageTypes";
import LibTableHeader "tableHeader/libTableHeader";
import LibMainIndexTable "mainIndexTable/libMainIndexTable";
import LibParentIndexTable "parentIndexTable/libParentIndexTable";

module {

    public class libIndexTables(
        memoryStorageToUse : MemoryStorageTypes.MemoryStorage,
        tableIndexMaxEntriesToUse : Nat64,
    ) {

        private let memoryStorage : MemoryStorageTypes.MemoryStorage = memoryStorageToUse;
        private let offsets_IndexTableHeader = CommonTypes.Offsets_IndexTableHeader;
        private let offsets_IndexTable = CommonTypes.Offset_IndexTable;
        private let tableIndexMaxEntries : Nat64 = tableIndexMaxEntriesToUse;

        public let tableHeader = LibTableHeader.libTableHeader(memoryStorageToUse,tableIndexMaxEntriesToUse);
        public let mainIndexTable = LibMainIndexTable.libMainIndexTable(memoryStorageToUse,tableIndexMaxEntriesToUse);
        public let parentIndexTable = LibParentIndexTable.libParentIndexTable(memoryStorageToUse,tableIndexMaxEntriesToUse);


        
        
        // public func create_new_index_tables(wrappedBlobMemoryAddress : Nat64): (Nat64, Nat64,Nat64){

        //     let table1MemoryAddress:Nat64 = create_new_index_table1(wrappedBlobMemoryAddress, null,null);
        //     let table2MemoryAddress:Nat64 = create_new_index_table2or3(table1MemoryAddress,null,null,1);
        //     let table3MemoryAddress:Nat64 = create_new_index_table2or3(table2MemoryAddress,null,null,1);

        //     return (table1MemoryAddress, table2MemoryAddress, table3MemoryAddress);
        // };

        // public func table_header_create_new(mainIndexTableAddress : Nat64) : Nat64 {
        //     libTableHeader.create_new(mainIndexTableAddress);
        // };

        // public func main_index_table_create_new():Nat64{
        //     libMainIndexTable.create_new();
        // };

        // private func update_previous_bucket_address(tableAddress:Nat64, previousBucketAddress:Nat64){
        //     Region.storeNat64(
        //         memoryStorage.memory_region.region,
        //         tableAddress + offsets.offset_previousBucket,
        //         previousBucketAddress
        //     );
        // };

        //   private func update_next_bucket_address(tableAddress:Nat64, nextBucketAddress:Nat64){
        //     Region.storeNat64(
        //         memoryStorage.memory_region.region,
        //         tableAddress + offsets.offset_nextBucket,
        //         nextBucketAddress
        //     );
        // };

        // public func get_list_entries_count(tableAddress:Nat64):Nat8{
        //     Region.loadNat8(
        //         memoryStorage.memory_region.region,
        //         tableAddress + offsets.offset_entriesCount
        //     );
        // };

        // public func update_list_entries_count(tableAddress:Nat64, newItemsCount:Nat8){
        //     Region.storeNat8(
        //         memoryStorage.memory_region.region,
        //         tableAddress + offsets.offset_entriesCount,
        //         newItemsCount
        //     );
        // };

        // private func table1_insert_address_internal(tableAddress:Nat64, index:Nat8,wrappedBlobMemoryAddress : Nat64){
        //     let headerBytesNeeded:Nat64 = 25; //Nat64.fromNat( (3 * 8) + 1);
        //     let indexNat64:Nat64 = Nat64.fromNat(Prim.nat8ToNat(index));
        //     let memoryPosition = headerBytesNeeded + 8 * indexNat64;

        //     // Store the wrapped-blob memory address
        //     Region.storeNat64(
        //         memoryStorage.memory_region.region,
        //         tableAddress + memoryPosition,
        //         wrappedBlobMemoryAddress
        //     );
        // };

        // private func table2or3_insert_address_internal(
        //     tableAddress:Nat64,
        //     index:Nat8,
        //     addressToAdd : Nat64,
        //     specificCountToAdd:Nat64
        //     ){
        //     let headerBytesNeeded:Nat64 = 33; //Nat64.fromNat( (4 * 8) + 1);
        //     let indexNat64:Nat64 = Nat64.fromNat(Prim.nat8ToNat(index));
        //     let memoryPosition = headerBytesNeeded + 16 * indexNat64;

        //     // Store the specific count
        //     Region.storeNat64(
        //         memoryStorage.memory_region.region,
        //         tableAddress + memoryPosition,
        //         specificCountToAdd
        //     );

        //     // Store the wrapped-blob memory address
        //     Region.storeNat64(
        //         memoryStorage.memory_region.region,
        //         tableAddress + memoryPosition + 8,
        //         addressToAdd
        //     );
        // };

        // private func table2Or3_increase_total_specific_count(tableAddress:Nat64,specificCountToAdd:Nat64){

        //     var totalSpecificCount:Nat64 =
        //     Region.loadNat64(memoryStorage.memory_region.region,tableAddress + offsets.offset_totalSpecificCount);

        //     totalSpecificCount:=totalSpecificCount + specificCountToAdd;

        //     Region.storeNat64(
        //         memoryStorage.memory_region.region,
        //         tableAddress + offsets.offset_totalSpecificCount,
        //         totalSpecificCount
        //     );
        // };

        // private func table2Or3_decrease_total_specific_count(tableAddress:Nat64,specificCountToReduce:Nat64){

        //     var totalSpecificCount:Nat64 =
        //     Region.loadNat64(memoryStorage.memory_region.region,tableAddress + offsets.offset_totalSpecificCount);

        //     totalSpecificCount:= totalSpecificCount - specificCountToReduce;
        //     totalSpecificCount:= Nat64.max(totalSpecificCount,0);

        //     Region.storeNat64(
        //         memoryStorage.memory_region.region,
        //         tableAddress + offsets.offset_totalSpecificCount,
        //         totalSpecificCount
        //     );
        // };

        // private func table1_append_address(table1Address:Nat64, addressToStore : Nat64)
        // :(Bool /*new table was created*/, Nat64 /*Address of new table*/){

        //     let itemsCount = get_list_entries_count(table1Address);
        //     if (itemsCount < 100){
        //         table1_insert_address_internal(table1Address,itemsCount, addressToStore);
        //         update_list_entries_count(table1Address, itemsCount + 1);
        //         return (false, 0);
        //     };

        //     let newTableAddress = create_new_index_table1(addressToStore,?table1Address, null);
        //     update_next_bucket_address(table1Address, newTableAddress);

        //     return (true, newTableAddress);
        // };

        // private func table2or3_append_address(tableAddress:Nat64, addressToStore : Nat64,specificCount:Nat64)
        // :(Bool /*new table was created*/, Nat64 /*Address of new table*/){

        //     let itemsCount = get_list_entries_count(addressToStore);
        //     if (itemsCount < 100){
        //         table2or3_insert_address_internal(tableAddress,itemsCount, addressToStore,specificCount);
        //         update_list_entries_count(tableAddress, itemsCount + 1);
        //         table2Or3_increase_total_specific_count(tableAddress,specificCount);
        //         return (false, 0);
        //     };

        //     let newTableAddress = create_new_index_table2or3(addressToStore,?tableAddress, null, specificCount);
        //     update_next_bucket_address(tableAddress, newTableAddress);

        //     return (true, newTableAddress);
        // };h

        // public func append_new_wrapped_blob_address(wrappedBlobMemoryAddress : Nat64,
        // lastTable1MemoryAddress:Nat64, lastTable2MemoryAddress:Nat64, lastTable3MemoryAddress:Nat64)
        // :(?Nat64, ?Nat64, ?Nat64){

        //     var lastTable1Address:?Nat64 = null;
        //     var lastTable2Address:?Nat64 = null;
        //     var lastTable3Address:?Nat64 = null;

        //     let result1:(Bool, Nat64) = table1_append_address(lastTable1MemoryAddress,wrappedBlobMemoryAddress );
        //     // let newTable1WasCreated = result1.0;
        //     // lastTable1Address:= ?result1.1;

        //     var result2:(Bool, Nat64) = (false,0);
        //     var result3:(Bool, Nat64) = (false,0);

        //     if (result1.0 == true){
        //         lastTable1Address:= ?result1.1;
        //         result2:= table2or3_append_address(lastTable2MemoryAddress,result1.1, 1);
        //     } else{
        //         result2:= table2or3_append_address(lastTable2MemoryAddress,result1.1, 1);
        //     };

        //     if (newTable1WasCreated== true){

        //         let result2 = table2or3_append_address(lastTable2MemoryAddress,result1.1, 1);
        //         let newTable2WasCreated = result2.0;
        //           if (newTable2WasCreated== true){
        //             lastTable2Address:=?result2.1;

        //             let result3 = table2or3_append_address(lastTable3MemoryAddress,result2.1, 1);
        //             let newTable3WasCreated = result3.0;
        //             if (newTable3WasCreated == true){
        //                 lastTable3Address:= ?result3.1;
        //             }
        //           };
        //     };

        //     return (lastTable1Address,lastTable2Address, lastTable3Address );
        // };

        // public func create_new_index_table1(memoryAddressToAdd : Nat64,
        //  previousTableAddress:?Nat64, nextTableAddress:?Nat64) : Nat64 {

        //     let headerBytesNeeded = 25; //(3 * 8) + 1;
        //     let contentBytesNeeded = 100 * 8 ; // 100 * Nat64

        //     let totalBytesNeeded = headerBytesNeeded + contentBytesNeeded;

        //     let memoryAddress = MemoryRegion.allocate(memoryStorage.memory_region, totalBytesNeeded);
        //     let memoryAddressNat64 : Nat64 = Nat64.fromNat(memoryAddress);

        //     let tableAddressPrevious:Nat64 = Option.get<Nat64>(previousTableAddress,memoryAddressNat64 );
        //     let tableAddressNext:Nat64 = Option.get<Nat64>(nextTableAddress, memoryAddressNat64);

        //     let region = memoryStorage.memory_region.region;

        //     // Set entries count to 1
        //     Region.storeNat8(region, memoryAddressNat64 + offsets.offset_entriesCount, 1);

        //     // Set identifier
        //     Region.storeNat64(region, memoryAddressNat64 + offsets.offset_identifier, CommonTypes.identifierIndexTable);

        //     // Set next Address to own address
        //     Region.storeNat64(region, memoryAddressNat64 + offsets.offset_nextBucket, tableAddressNext);

        //     // Set previous Address to own address
        //     Region.storeNat64(region, memoryAddressNat64 + offsets.offset_previousBucket, tableAddressPrevious);

        //     // Store the wrapped-blob memory address
        //     Region.storeNat64(
        //         region,
        //         memoryAddressNat64 + Nat64.fromNat(headerBytesNeeded),
        //         memoryAddressToAdd,
        //     );

        //     return memoryAddressNat64;
        // };

        // public func create_new_index_table2or3(
        //     memoryAddressToAdd : Nat64,
        //     previousTableAddress:?Nat64,
        //     nextTableAddress:?Nat64,
        //     specificCount:Nat64,
        //  ) : Nat64 {

        //     let headerBytesNeeded = 33; //(4 * 8) + 1;
        //     let contentBytesNeeded = 100 * 16 ; // 100 * (2 * Nat64)

        //     let totalBytesNeeded = headerBytesNeeded + contentBytesNeeded;

        //     let memoryAddress = MemoryRegion.allocate(memoryStorage.memory_region, totalBytesNeeded);
        //     let memoryAddressNat64 : Nat64 = Nat64.fromNat(memoryAddress);

        //     let tableAddressPrevious:Nat64 = Option.get<Nat64>(previousTableAddress,memoryAddressNat64 );
        //     let tableAddressNext:Nat64 = Option.get<Nat64>(nextTableAddress, memoryAddressNat64);

        //     let region = memoryStorage.memory_region.region;

        //     // Set entries count to 1
        //     Region.storeNat8(region, memoryAddressNat64 + offsets.offset_entriesCount, 1);

        //     // Set identifier
        //     Region.storeNat64(region, memoryAddressNat64 + offsets.offset_identifier, CommonTypes.identifierIndexTable);

        //     // Set next Address to own address
        //     Region.storeNat64(region, memoryAddressNat64 + offsets.offset_nextBucket, tableAddressNext);

        //     // Set previous Address to own address
        //     Region.storeNat64(region, memoryAddressNat64 + offsets.offset_previousBucket, tableAddressPrevious);

        //     // Set sum of all specific count for this bucket
        //     Region.storeNat64(region, memoryAddressNat64 + offsets.offset_totalSpecificCount, specificCount);

        //     // Store the specific count value
        //     Region.storeNat64(
        //         region,
        //         memoryAddressNat64 + Nat64.fromNat(headerBytesNeeded),
        //         specificCount,
        //     );

        //     // Store the wrapped-blob memory address
        //     Region.storeNat64(
        //         region,
        //         memoryAddressNat64 + Nat64.fromNat(headerBytesNeeded + 1),
        //         memoryAddressToAdd,
        //     );

        //     return memoryAddressNat64;
        // };
    };

};
