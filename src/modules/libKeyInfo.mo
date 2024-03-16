import Blob "mo:base/Blob";
import HashListTypes "../types/hashListTypes";
import StableTrieMap "mo:StableTrieMap";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Region "mo:base/Region";
import Iter "mo:base/Iter";
import List "mo:base/List";
import Binary "../helpers/binary";
import Itertools "mo:itertools/Iter";
import Option "mo:base/Option";
import Debug "mo:base/Debug";
import { MemoryRegion } "mo:memory-region";
import GlobalFunctions "../helpers/globalFunctions";
import CommonTypes "../types/commonTypes";
import KeyInfoTypes "../types/keyInfo/keyInfoTypes";

module {

    public class libKeyInfo(memoryStorageToUse : CommonTypes.MemoryStorage) {

        private let memoryStorage = memoryStorageToUse;
        private var blobHashFunc = GlobalFunctions.blobHash;
        private var nat32IdentityFunc = GlobalFunctions.nat32Identity;
       // private let libBucketsIndexer = LibBucketsIndexer.libBucketsIndexer(memoryStorageToUse);
        private let offset = CommonTypes.Offsets_KeyInfo;
        private let keyinfo_identifier:Nat64 = CommonTypes.identifier_KeyInfo;

        // public func get_address_of_last_stored_blob(keyInfoAddress : Nat64) : Nat64 {
        //     Region.loadNat64(memoryStorage.memory_region.region, keyInfoAddress + offset.endAddressWrappedBlob);
        // };

        public func get_address_of_index_table_header(keyInfoAddress:Nat64):Nat64{
            Region.loadNat64(memoryStorage.memory_region.region, keyInfoAddress + offset.addressOfIndexTableHeader);
        };

        public func exist_keyinfo_on_address(memoryAddress : Nat64) : Bool {
            let identifier = Region.loadNat64(memoryStorage.memory_region.region, memoryAddress + offset.identifier);
            return identifier == CommonTypes.identifier_KeyInfo;
        };

    //    public func update_last_wrappedblob_address(keyinfoMemoryAddress : Nat64,
    //     lastWrappedBlobMemoryAddress:Nat64){
 
    //         // set memory address of last wrapped blob
    //         Region.storeNat64(
    //             memoryStorage.memory_region.region, 
    //             keyinfoMemoryAddress + offsets.endAddressWrappedBlob, 
    //             lastWrappedBlobMemoryAddress
    //         );
    //     };


        public func get_correct_keyinfo_address(
            key : Blob,
            possibleAddresses : List.List<Nat64>,
        ) : (Bool /*found*/, Nat64 /*address*/) {
            if (List.size<Nat64>(possibleAddresses) == 0) {
                return (false, 0);
            };
            let region = memoryStorage.memory_region.region;
            let keySize : Nat = key.size();
            let keySizeNat64 : Nat64 = Nat64.fromNat(keySize);

            for (address : Nat64 in List.toIter<Nat64>(possibleAddresses)) {

                if (exist_keyinfo_on_address(address) == true) {
                    let sizeOfKey : Nat64 = Region.loadNat64(region, address + offset.sizeOfKeyBlob);
                    if (sizeOfKey == keySizeNat64) {
                        let keyBlob = Region.loadBlob(region, address + offset.keyAsBlob, keySize);
                        if (Blob.equal(keyBlob, key) == true) {
                            return (true, address);
                        };
                    };
                };
            };

            return (false, 0);
        };

         // Add completely new keyInfo entry for the new key
        public func create_new(key : Blob, indexTableHeaderAddress:Nat64) : Nat64 {

            let keySize = key.size();
            let sizeNeeded : Nat = Nat64.toNat(offset.minBytesNeeded) + keySize;
            let sizeNeededNat64 : Nat64 = Nat64.fromNat(sizeNeeded);
            let region = memoryStorage.memory_region.region;

            //allocate memory
            let keyInfoMemoryAddress : Nat = MemoryRegion.allocate(memoryStorage.memory_region, sizeNeeded);
            let keyInfoMemoryNat64 : Nat64 = Nat64.fromNat(keyInfoMemoryAddress);

            // total size
            Region.storeNat64(region, keyInfoMemoryNat64 + offset.totalSize, sizeNeededNat64);

            // Keyinfo-identifier
            Region.storeNat64(region, keyInfoMemoryNat64 + offset.identifier, keyinfo_identifier);

            // size of key
            Region.storeNat64(region, keyInfoMemoryNat64 + offset.sizeOfKeyBlob, Nat64.fromNat(keySize));

            // memory address of index-table-header
            Region.storeNat64(region, keyInfoMemoryNat64 + offset.addressOfIndexTableHeader, indexTableHeaderAddress);

            // memory address of associated-key-table-header (add keyinfo-address for now, because we do not know the real address,yet)
            Region.storeNat64(region, keyInfoMemoryNat64 + offset.addressOfAssociatedKeyTableHeader, 0);

            // store key as blob
            Region.storeBlob(region, keyInfoMemoryNat64 + offset.keyAsBlob, key);

            return keyInfoMemoryNat64;
        };


        // public func get_last_tableAddresses(keyinfoMemoryAddress : Nat64):(Nat64, Nat64, Nat64){
        //     let region = memoryStorage.memory_region.region;
            
        //     // last memory address of table1
        //     let table1Address = Region.loadNat64(region, keyinfoMemoryAddress + offsets.offset_lastAddressOfIndexTable1);

        //     // last memory address of table2
        //     let table2Address = Region.loadNat64(region, keyinfoMemoryAddress + offsets.offset_lastAddressOfIndexTable2);

        //     // last memory address of table3
        //     let table3Address = Region.loadNat64(region, keyinfoMemoryAddress + offsets.offset_lastAddressOfIndexTable3);

        //     return (table1Address,table2Address,table3Address);
        // };

        // public func update_last_tableAddresses(
        //     keyInfoAddress:Nat64,
        //     lastTable1AddressOrNull:?Nat64, 
        //     lastTable2AddressOrNull:?Nat64, 
        //     lastTable3AddressOrNull:?Nat64
        // ){

        //     let region = memoryStorage.memory_region.region;
        //      switch(lastTable1AddressOrNull){
        //         case (?table1Address){
        //             Region.storeNat64(region, keyInfoAddress + offsets.offset_lastAddressOfIndexTable1,table1Address);
        //         };
        //         case (_){
        //             // nothing to change
        //         };
        //      };

        //      switch(lastTable2AddressOrNull){
        //         case (?table2Address){
        //             Region.storeNat64(region, keyInfoAddress + offsets.offset_lastAddressOfIndexTable2,table2Address);
        //         };
        //         case (_){
        //             // nothing to change
        //         };
        //      };

        //        switch(lastTable3AddressOrNull){
        //         case (?table3Address){
        //             Region.storeNat64(region, keyInfoAddress + offsets.offset_lastAddressOfIndexTable3,table3Address);
        //         };
        //         case (_){
        //             // nothing to change
        //         };
        //      };
        // };

 


        // public func total_items_count_increase(keyInfoAddress:Nat64, increaseValue:Nat64){

        //     var itemsCount:Nat64 = Region.loadNat64(
        //         memoryStorage.memory_region.region, 
        //         keyInfoAddress + offsets.offset_valueItemsCount
        //     );

        //     itemsCount:=itemsCount + increaseValue;
        
        //     Region.storeNat64(
        //         memoryStorage.memory_region.region, 
        //         keyInfoAddress + offsets.offset_valueItemsCount, 
        //         itemsCount
        //     );
        // };

        // public func total_items_count_decrease(keyInfoAddress:Nat64, decreaseValue:Nat64){

        //     var itemsCount:Nat64 = Region.loadNat64(
        //         memoryStorage.memory_region.region, 
        //         keyInfoAddress + offsets.offset_valueItemsCount
        //     );
        
        //     itemsCount:=itemsCount - decreaseValue;
        //     itemsCount:=Nat64.max(itemsCount, 0);

        //     Region.storeNat64(
        //         memoryStorage.memory_region.region, 
        //         keyInfoAddress + offsets.offset_valueItemsCount, 
        //         itemsCount
        //     );
        // };

       

        // public func get_keyinfo_from_memory(memoryStorage : MemoryStorage, address : Nat64):KeyInfo {
        //     let totalBytes : Nat64 = Region.loadNat64(memoryStorage.memory_region.region, address);
        //     let sizeOfBlobKey : Nat64 = Region.loadNat64(memoryStorage.memory_region.region, address + 8);
        //     let addressOfwrappedBlob : Nat64 = Region.loadNat64(memoryStorage.memory_region.region, address + 16);
        //     let blobKey : Blob = Region.loadBlob(
        //         memoryStorage.memory_region.region,
        //         address + 24,
        //         Nat64.toNat(sizeOfBlobKey),
        //     );

        //     return {
        //         totalSize : Nat64 = totalBytes;
        //         sizeOfKeyBlob : Nat64 = sizeOfBlobKey;
        //         wrappedBlobAddress : Nat64 = addressOfwrappedBlob;
        //         keyAsBlob : Blob = blobKey;
        //     };

        // };

        // // Convert keyinfo as blob into keyinfo type
        // public func convert_keyinfo_blob_to_keyinfo(blob : Blob) : KeyInfo {

        //     let blobArray = Blob.toArray(blob);
        //     let totalBytes : Nat64 = Binary.LittleEndian.toNat64(Iter.toArray(Itertools.fromArraySlice(blobArray, 0, 8)));
        //     let internalBlobSize : Nat64 = Binary.LittleEndian.toNat64(Iter.toArray(Itertools.fromArraySlice(blobArray, 8, 16)));
        //     let address : Nat64 = Binary.LittleEndian.toNat64(Iter.toArray(Itertools.fromArraySlice(blobArray, 16, 24)));
        //     let internalBlob : Blob = Blob.fromArray(Iter.toArray(Itertools.fromArraySlice(blobArray, 24, 24 + Nat64.toNat(internalBlobSize))));

        //     let result : KeyInfo = {
        //         totalSize : Nat64 = totalBytes;
        //         sizeOfKeyBlob : Nat64 = internalBlobSize;
        //         wrappedBlobAddress : Nat64 = address;
        //         keyAsBlob : Blob = internalBlob;
        //     };

        //     return result;
        // };

        // // Convert keyinfo-type to blob
        // public func convert_keyinfo_to_blob(keyInfo : KeyInfo) : Blob {

        //     let blobSizeBytes : Nat64 = Nat64.fromNat(keyInfo.keyAsBlob.size());
        //     let totalBytes : Nat64 = blobSizeBytes + 24;

        //     let blob_totalSize : [Nat8] = Binary.LittleEndian.fromNat64(totalBytes);
        //     let blob_sizeOfKeyBlob : [Nat8] = Binary.LittleEndian.fromNat64(blobSizeBytes);
        //     let blob_address : [Nat8] = Binary.LittleEndian.fromNat64(keyInfo.wrappedBlobAddress);

        //     var iter = Iter.fromArray(blob_totalSize);
        //     iter := Itertools.chain(iter, Iter.fromArray(blob_sizeOfKeyBlob));
        //     iter := Itertools.chain(iter, Iter.fromArray(blob_address));
        //     iter := Itertools.chain(iter, Iter.fromArray(Blob.toArray(keyInfo.keyAsBlob)));

        //     let result : Blob = Blob.fromArray(Iter.toArray(iter));
        //     return result;

        // };

        // // Get keyinfo by key
        // public func get_keyinfo(key : Blob, memoryStorage : MemoryStorage) : (?KeyInfo, Nat64 /*address of keyinfo*/) {

        //     var keySize = Nat64.fromNat(key.size());
        //     var keyHash : Nat32 = Blob.hash(key);

        //     let valuesList = libIndexMapping.get_values(key, memoryStorage);
        //     let listSize : Nat = List.size(valuesList);
        //     if (listSize == 0) {
        //         return (null, 0);
        //     };

        //     for (index in Iter.range(0, listSize -1)) {
        //         let indexOrNull = List.get(valuesList, index);
        //         switch (indexOrNull) {
        //             case (?foundAddress) {
        //                 let keyInfo : KeyInfo = get_keyinfo_internal(memoryStorage, foundAddress);
        //                 if (keyInfo.sizeOfKeyBlob == keySize) {
        //                     if (Blob.equal(keyInfo.keyAsBlob, key) == true) {
        //                         return (Option.make(keyInfo), foundAddress);
        //                     };
        //                 };
        //             };
        //             case (_) {
        //                 // do nothing
        //             };

        //         };
        //     };

        //     return (null, 0);

        // };

        // // Store the new KeyInfo into memory
        // public func add_new_keyinfo_directly_into_memory(memoryStorage : MemoryStorage, keyinfo_as_blob : Blob) : Nat64 {
        //     let keyInfoAddress = MemoryRegion.addBlob(memoryStorage.memory_region, keyinfo_as_blob);
        //     let keyInfoAddressNat64 : Nat64 = Nat64.fromNat(keyInfoAddress);
        //     return keyInfoAddressNat64;
        // };

        // // Update the wrappedBlob-memory-Adress
        // public func update_wrappedBlob_address(
        //     memoryStorage : MemoryStorage,
        //     keyInfoAddress : Nat64,
        //     wrappedBlobAddress : Nat64,
        // ) {
        //     let memoryOffsetWrappedBlobAddress : Nat64 = keyInfoAddress + 16;
        //     Region.storeNat64(memoryStorage.memory_region.region, memoryOffsetWrappedBlobAddress, wrappedBlobAddress);
        // };

        // // Delete keyinfo by memory address
        // public func delete_keyinfo(memoryStorage : MemoryStorage, keyInfoAddress : Nat64) {

        //     let keyInfoSize : Nat64 = Region.loadNat64(memoryStorage.memory_region.region, keyInfoAddress);
        //     ignore MemoryRegion.removeBlob(
        //         memoryStorage.memory_region,
        //         Nat64.toNat(keyInfoAddress),
        //         Nat64.toNat(keyInfoSize),
        //     );

        // };

        // private func get_keyinfo_internal(memoryStorage : MemoryStorage, address : Nat64) : KeyInfo {
        //     let sizeNeeded = Region.loadNat64(memoryStorage.memory_region.region, address);
        //     let keyInfoBlob : Blob = MemoryRegion.loadBlob(memoryStorage.memory_region, Nat64.toNat(address), Nat64.toNat(sizeNeeded));
        //     let result = get_keyinfo_from_memory(memoryStorage, address);
        //     return result;
        // };
    };
};
