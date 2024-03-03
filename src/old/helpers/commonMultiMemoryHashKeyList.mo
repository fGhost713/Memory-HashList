import StableTrieMap "mo:StableTrieMap";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Text "mo:base/Text";
import Region "mo:base/Region";
import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import List "mo:base/List";
import Hash "mo:base/Hash";
import Nat8 "mo:base/Nat8";
import Binary "../../helpers/binary";
import Itertools "mo:itertools/Iter";
import Principal "mo:base/Principal";
import Option "mo:base/Option";
import Result "mo:base/Result";
import Float "mo:base/Float";
import Int64 "mo:base/Int64";
import { MemoryRegion } "mo:memory-region";
import memoryHashListTypes "../types/memoryHashListTypes";

module {

    public type MemoryStorage = memoryHashListTypes.MemoryStorage;
    public type KeyInfo = memoryHashListTypes.KeyInfo;
    public type WrappedBlobStoreItem = memoryHashListTypes.WrappedBlobStoreItem;
    
    public func get_new_memory_storage() : MemoryStorage {
        let newItem : MemoryStorage = {
            memory_region = MemoryRegion.new();
            index_mappings = StableTrieMap.new();
        };
        return newItem;
    };




    public func show_memory_used(item : MemoryStorage): (Text){
          let sizeBytes =  item.memory_region.size;
          let sizeKiloBytes:Float =  Float.fromInt64(Int64.fromNat64(Nat64.fromNat(sizeBytes))) / 1024;
          let sizeMegabytes:Float = sizeKiloBytes / 1024;
          let sizeGigabytes:Float = sizeMegabytes / 1024;

          let returnText = "bytes: " # debug_show(sizeBytes)#" / kb: " # debug_show(sizeKiloBytes) #" / mb: "#debug_show(sizeMegabytes) #" / gb: "#debug_show(sizeGigabytes);
          return returnText;
    };


    //------------------------------------------------------------------------------------------------------
    // Multi-blob usage. The value will be list of values. (You can imagine of something like Dictionary<key, List<blob>> )

    public func multiBlob_append(key : Blob, item : MemoryStorage, blobToStore : Blob) : (Nat64 /* keyInfo address*/, Nat64 /*stored blob address*/) {
        let getKeyInfoResult : (?KeyInfo, Nat64) = get_KeyInfo(key, item);
        let keyInfoOrNull = getKeyInfoResult.0;
        let keyInfoAddress = getKeyInfoResult.1;

        switch (keyInfoOrNull) {
            case (?keyInfo) {

                let lastUsedIndex = keyInfo.lastUsedIndex;

                // store the blob now and get the stored-address
                let newItemAddress = put_wrappedBlobStoreItem_Internal(key, item, blobToStore);

                // update the nextIndex-value of previous last item
                set_nextIndex_in_wrappedBlobStoreItem(item, lastUsedIndex, newItemAddress);

                // update the previousIndex-value of new item and set the nextIndex-value to own address
                set_previousIndex_in_wrappedBlobStoreItem(item, newItemAddress, lastUsedIndex);
                set_nextIndex_in_wrappedBlobStoreItem(item, newItemAddress, newItemAddress);

                // update last used index in corresponding KeyInfo item
                keyInfo_update_lastused_index(keyInfoAddress, item, newItemAddress);

                return (keyInfoAddress, newItemAddress);
            };
            case (_) {
                //The key was not used before
                let resultIndizes = put_new_blob_internal(key, item, blobToStore);
                return resultIndizes;
            };
        };
    };

    // Get all the memory addresses for the stored blob-values for the corresponding key.
    public func multiBlob_GetAllAddresses(key : Blob, item : MemoryStorage) : [Nat64] {
        let getKeyInfoResult : (?KeyInfo, Nat64) = get_KeyInfo(key, item);
        let keyInfoOrNull = getKeyInfoResult.0;
        let keyInfoAddress = getKeyInfoResult.1;

        switch (keyInfoOrNull) {
            case (?keyInfo) {

                let firstUsedIndex = keyInfo.firstUsedIndex;
                var resultList : List.List<Nat64> = List.nil<Nat64>();
                resultList := List.push<Nat64>(firstUsedIndex, resultList);

                var nextItemAddress = firstUsedIndex;

                var listRetrievalCompleted : Bool = false;
                while (listRetrievalCompleted == false) {

                    let currentItemAdress = nextItemAddress;
                    nextItemAddress := wrappedBlobStore_getNextAddress(item, nextItemAddress);

                    if (nextItemAddress == currentItemAdress) {
                        listRetrievalCompleted := true;
                    } else {
                        resultList := List.push<Nat64>(nextItemAddress, resultList);
                    };
                };

                return List.toArray(List.reverse(resultList));
            };
            case (_) {
                //The key was not used before
                return [];
            };
        };
    };

    /// Return the blob from the provided address
    public func multiBlob_GetBlob_by_address(key : Blob, item : MemoryStorage, address : Nat64) : ?Blob {
        let wrappedItemOrNull = get_wrappedBlob_internal(key, item, address);
        switch(wrappedItemOrNull){
            case (?wrappedItem){
                return Option.make(wrappedItem.valueAsBlob);
            };
            case (_){
                return null;
            };
        }  
    };


    /// Return the blob from the provided start index and count
    public func multiBlob_GetBlobs_by_index_and_count(key : Blob, item : MemoryStorage, index : Nat64, count:Nat64) : [Blob] {
        
        if (count == 0){
            return [];
        };

        let getKeyInfoResult : (?KeyInfo, Nat64) = get_KeyInfo(key, item);
        let keyInfoOrNull = getKeyInfoResult.0;
        let keyInfoAddress = getKeyInfoResult.1;

        let lastIndex = index + count - 1;
        switch (keyInfoOrNull) {
            case (?keyInfo) {

                let firstUsedIndex = keyInfo.firstUsedIndex;
                var resultList : List.List<Blob> = List.nil<Blob>();
                var currentIndex:Nat64 = 0;

                if (currentIndex >= index and currentIndex <=lastIndex ){

                    let wrappedBlob = get_wrappedBlob_directly_internal(item,firstUsedIndex);
                    resultList := List.push<Blob>(wrappedBlob.valueAsBlob, resultList);     
                };
                

                var nextItemAddress = firstUsedIndex;

                var listRetrievalCompleted : Bool = false;
                while (listRetrievalCompleted == false) {
                    
                    currentIndex:=currentIndex + 1;

                    let currentItemAdress = nextItemAddress;
                    nextItemAddress := wrappedBlobStore_getNextAddress(item, nextItemAddress);

                    if (nextItemAddress == currentItemAdress) {
                        listRetrievalCompleted := true;
                    } else {
                        if (currentIndex >= index and currentIndex <=lastIndex ){

                            let wrappedBlob = get_wrappedBlob_directly_internal(item,nextItemAddress);
                            resultList := List.push<Blob>(wrappedBlob.valueAsBlob, resultList);    
                        };
                    };
                };

                return List.toArray(List.reverse(resultList));
            };
            case (_) {
                //The key was not used before
                return [];
            };
        };
        
    };

    /// Return the blob from the provided index
    public func multiBlob_GetBlob_by_index(key : Blob, item : MemoryStorage, index : Nat64) : ?Blob {
        
        
        let resultArray = multiBlob_GetBlobs_by_index_and_count(key, item, index, 1);
        if (resultArray.size() == 0){
            return null;
        };

        return Option.make(resultArray[0]);
    };

    /// All the stored Blobs for the provided 'key' are returned.
    public func multiBlob_GetAllBlobs(key : Blob, item : MemoryStorage) : [Blob] {

        var blobsArray = multiBlob_GetAllBlobsWithAdresses(key, item);
        let arraySize = blobsArray.size();
        if (arraySize == 0) {
            return [];
        };

        var resultList : List.List<Blob> = List.nil<Blob>();
        for (index in Iter.range(0, arraySize -1)) {

            let item : (Blob, Nat64 /*address*/) = blobsArray[index];
            resultList := List.push<Blob>(item.0, resultList);

        };
        return List.toArray(List.reverse(resultList));
    };

    /// All the stored Blobs with corresponding memory-addresses for the provided 'key' are returned.
    public func multiBlob_GetAllBlobsWithAdresses(key : Blob, item : MemoryStorage) : [(Blob, Nat64 /*address*/)] {

        let allAddresses = multiBlob_GetAllAddresses(key, item);
        let arraySize = allAddresses.size();
        if (arraySize == 0) {
            return [];
        };

        var resultList : List.List<(Blob, Nat64)> = List.nil<(Blob, Nat64)>();
        for (arrayIndex in Iter.range(0, arraySize -1)) {
            let address = allAddresses[arrayIndex];
            let wrappedItem = get_wrappedBlob_directly_internal(item, address);
            resultList := List.push<(Blob, Nat64)>((wrappedItem.valueAsBlob, address), resultList);

        };
        return List.toArray(List.reverse(resultList));
    };

    // Delete an entry by key and address
    public func multiBlob_delete(key : Blob, item : MemoryStorage, address : Nat64):Result.Result<Blob,Text> {

        let keyInfoResult : (?KeyInfo, Nat64) = get_KeyInfo(key, item);
        var keyInfo:KeyInfo = get_default_keyInfo();
        switch(keyInfoResult.0){
            case (?foundKeyInfo){
                keyInfo:=foundKeyInfo;
            };
            case (_){
                return #err("The key not exist");
            };
        };

        let itemExistAtAddress = wrappedBlob_exist(key,item, address);
        if (itemExistAtAddress == false){
            return #err("No item exist at this address for the provided key");
        };

        let keyInfoAddress : Nat64 = keyInfoResult.1;

        let blobSize = wrappedBlobStore_getTotalSize(item, address);
        let deletedBlob : Blob = MemoryRegion.removeBlob(item.memory_region, Nat64.toNat(address), Nat64.toNat(blobSize));
        let deletedItem : WrappedBlobStoreItem = blob_to_WrappedBlobStoreItem(deletedBlob);

        let prevAddress = deletedItem.previousAddress;
        let nextAddress = deletedItem.nextAddress;

        if (prevAddress != address) {

            // If we are here: previous item exist => Means deleted item was not the first item

            if (nextAddress != address) {
                // If we are here: next item exist => Means deleted item was not the last item
                set_nextIndex_in_wrappedBlobStoreItem(item, prevAddress, nextAddress);
                set_previousIndex_in_wrappedBlobStoreItem(item, nextAddress, prevAddress);

                return #ok(deletedItem.valueAsBlob);
            } else {
                // If we are here: next item not exist => Means deleted item was the last item
                set_nextIndex_in_wrappedBlobStoreItem(item, prevAddress, prevAddress);
                keyInfo_update_lastused_index(keyInfoAddress, item, prevAddress);
                return #ok(deletedItem.valueAsBlob);
            };
        } else {
            // If we are here: previous item not exist => means the deleted item is the first item

            if (nextAddress != address) {
                // If we are here: next item exist => Means the deleted item was not the last item
                set_previousIndex_in_wrappedBlobStoreItem(item, nextAddress, nextAddress);
                keyInfo_update_firstused_index(keyInfoAddress, item, nextAddress);
                return #ok(deletedItem.valueAsBlob);
            } else {
                // If we are here: next item not exist => Means the deleted item was the final existing item.
                keyInfo_delete(key, keyInfoAddress, item);
                return #ok(deletedItem.valueAsBlob);
            };
        };
    };

    public func multiBlob_delete_all(key : Blob, item : MemoryStorage) {

        var allAddresses = multiBlob_GetAllAddresses(key, item);
        let addressesCount = allAddresses.size();
        if (addressesCount == 0) {
            return;
        };

        let keyInfoResult : (?KeyInfo, Nat64) = get_KeyInfo(key, item);
        let keyInfoAddress : Nat64 = keyInfoResult.1;

        for (arrayIndex in Iter.range(0, addressesCount -1)) {
            let address = allAddresses[arrayIndex];
            let blobSize = wrappedBlobStore_getTotalSize(item, address);
            ignore MemoryRegion.removeBlob(item.memory_region, Nat64.toNat(address), Nat64.toNat(blobSize));
        };

        keyInfo_delete(key, keyInfoAddress, item);
    };

    //------------------------------------------------------------------------------------------------------

    //------------------------------------------------------------------------------------------------------
    // Single blob usage here. Means the HashList value will only contain one value and not list of values.
    // (You can imagine of something like Dictionary<key, blob> -> one key to exactly one blob )

    // Add or update single blob (for a specific key)
    public func singleBlob_put(key : Blob, item : MemoryStorage, blobToStore : Blob) {

        var keyAsNat32Hash = Blob.hash(key);

        let getKeyInfoResult : (?KeyInfo, Nat64) = get_KeyInfo(key, item);
        let keyInfoOrNull = getKeyInfoResult.0;

        switch (keyInfoOrNull) {
            case (?keyInfo) {

                //Only single-blob usage is used here. Therefore we can remove all and then add as new item:
                multiBlob_delete_all(key, item);
                ignore put_new_blob_internal(key, item, blobToStore);
            };
            case (_) {
                //The key was not used before
                ignore put_new_blob_internal(key, item, blobToStore);
            };
        };
    };

    public func singleBlob_delete(key : Blob, item : MemoryStorage) {
        multiBlob_delete_all(key, item);
    };

    public func singleBlob_get(key : Blob, item : MemoryStorage) : ?Blob {
        let allBlobs = multiBlob_GetAllBlobs(key, item);

        if (allBlobs.size() == 0) {
            return null;
        };

        return Option.make(allBlobs[0]);
    };
    //------------------------------------------------------------------------------------------------------

    //---------------------------------------------------------------------------------------------------------------------
    // WrappedBlobStoreItem helpers:

    private func wrappedBlobStore_getNextAddress(item : MemoryStorage, address : Nat64) : Nat64 {
        Region.loadNat64(item.memory_region.region, address + 8);
    };

    private func wrappedBlobStore_getTotalSize(item : MemoryStorage, address : Nat64) : Nat64 {
        Region.loadNat64(item.memory_region.region, address);
    };

    private func set_nextIndex_in_wrappedBlobStoreItem(item : MemoryStorage, address : Nat64, numberValueToStore : Nat64) {
        Region.storeNat64(item.memory_region.region, address + 8, numberValueToStore); //update the nextIndex-value
    };

    private func set_previousIndex_in_wrappedBlobStoreItem(item : MemoryStorage, address : Nat64, numberValueToStore : Nat64) {
        Region.storeNat64(item.memory_region.region, address + 16, numberValueToStore); //update the previousIndex-value
    };

    private func put_wrappedBlobStoreItem_Internal(key : Blob, item : MemoryStorage, blobToStore : Blob) : Nat64 {

        let blobSize = Nat64.fromNat(blobToStore.size());
        let storeItem : WrappedBlobStoreItem = {
            totalSize : Nat64 = blobSize + 32; // 32 bytes => 4 * Nat64 = 4 * 8 bytes = 32 bytes
            nextAddress : Nat64 = 0;
            previousAddress : Nat64 = 0;
            valueAsBlobSize : Nat64 = blobSize;
            valueAsBlob : Blob = blobToStore;
        };
        let blob_fromWrappedBlob : Blob = wrappedBlobStore_to_blob(storeItem);

        // store the blob into memory
        let valueStoredAddress = MemoryRegion.addBlob(item.memory_region, blob_fromWrappedBlob);
        let valueStoredAddressNat64 : Nat64 = Nat64.fromNat(valueStoredAddress);
        return valueStoredAddressNat64;

    };

    // If the key is not already existing then this method will be called, so that completely new entries will be added
    private func put_new_blob_internal(key : Blob, item : MemoryStorage, blobToStore : Blob) : (Nat64, Nat64) {

        var keyAsNat32Hash = Blob.hash(key);

        // store the blob into memory
        let valueStoredAddressNat64 : Nat64 = put_wrappedBlobStoreItem_Internal(key, item, blobToStore);

        // Update the next and previous address (so that it points to the item-index itself)
        // Because no real other previous or next item available at the moment.
        set_nextIndex_in_wrappedBlobStoreItem(item, valueStoredAddressNat64, valueStoredAddressNat64);
        set_previousIndex_in_wrappedBlobStoreItem(item, valueStoredAddressNat64, valueStoredAddressNat64);

        // Create and store the related KeyInfo
        let keyAsBlobSize : Nat64 = Nat64.fromNat(key.size());
        let newKeyInfo : KeyInfo = {
            totalSize : Nat64 = keyAsBlobSize + 32;
            sizeOfKeyBlob : Nat64 = keyAsBlobSize;
            firstUsedIndex : Nat64 = valueStoredAddressNat64;
            lastUsedIndex : Nat64 = valueStoredAddressNat64;
            keyAsBlob : Blob = key;
        };
        let newKeyInfoAsBlob : Blob = keyInfo_to_blob(newKeyInfo);

        // Store the KeyInfo into memory
        let keyInfoAddress = MemoryRegion.addBlob(item.memory_region, newKeyInfoAsBlob);
        let keyInfoAddressNat64 : Nat64 = Nat64.fromNat(keyInfoAddress);
        // Add entry in index_mappings
        var newList : List.List<Nat64> = List.nil<Nat64>();
        newList := List.push<Nat64>(keyInfoAddressNat64, newList);
        StableTrieMap.put(item.index_mappings, Nat32.equal, nat32Identity, keyAsNat32Hash, newList);

        return (keyInfoAddressNat64, valueStoredAddressNat64);
    };



    // Returns the wrapped blob by address - without checking before if the item exist.
    // So we must be sure that the item on that address exist.
    private func get_wrappedBlob_directly_internal(item : MemoryStorage, address : Nat64) : WrappedBlobStoreItem {
        let sizeNeeded = Region.loadNat64(item.memory_region.region, address);
        let blobResult : Blob = MemoryRegion.loadBlob(item.memory_region, Nat64.toNat(address), Nat64.toNat(sizeNeeded));
        return blob_to_WrappedBlobStoreItem(blobResult);
    };


    private func wrappedBlob_exist(key : Blob, item : MemoryStorage, address : Nat64):Bool{
        let itemOrNull = get_wrappedBlob_internal(key,item, address);
        switch(itemOrNull){
            case (?item){
                return true;
            };
            case (_){
                return false;
            }
        };
    };

    // Returns the wrapped blob by provided key and memory address.
    // Null is returned in case item not found.
    private func get_wrappedBlob_internal(key : Blob, item : MemoryStorage, address : Nat64) : ?WrappedBlobStoreItem {

        //First check if the address exist:
        let availableAddresses = multiBlob_GetAllAddresses(key, item);
        if (availableAddresses.size() == 0){
            return null;
        };

        let foundAddressOrNull:?Nat64 = Array.find<Nat64>(availableAddresses, func (n):Bool { n == address});
        switch(foundAddressOrNull){
            case (?foundAddress){
                // everything is fine, the address is used by the provided key
            };
            case (_){
                return null;
            };
        };

        let sizeNeeded = Region.loadNat64(item.memory_region.region, address);
        let blobResult : Blob = MemoryRegion.loadBlob(item.memory_region, Nat64.toNat(address), Nat64.toNat(sizeNeeded));
        return Option.make(blob_to_WrappedBlobStoreItem(blobResult));
    };

    /// Converts the WrappedBlobStore-type to blob
    private func wrappedBlobStore_to_blob(item : WrappedBlobStoreItem) : Blob {

        let blobSizeBytes : Nat64 = Nat64.fromNat(item.valueAsBlob.size());
        let totalBytes : Nat64 = blobSizeBytes + 32; // 32 bytes => 4 * Nat64 = 4 * 8 bytes = 32 bytes

        let blob_totalSize : [Nat8] = Binary.LittleEndian.fromNat64(totalBytes);
        let blob_nextAddress : [Nat8] = Binary.LittleEndian.fromNat64(item.nextAddress);
        let blob_previousAddress : [Nat8] = Binary.LittleEndian.fromNat64(item.previousAddress);
        let blob_valueAsBlobSize : [Nat8] = Binary.LittleEndian.fromNat64(item.valueAsBlobSize);

        var iter = Iter.fromArray(blob_totalSize);
        iter := Itertools.chain(iter, Iter.fromArray(blob_nextAddress));
        iter := Itertools.chain(iter, Iter.fromArray(blob_previousAddress));
        iter := Itertools.chain(iter, Iter.fromArray(blob_valueAsBlobSize));
        iter := Itertools.chain(iter, Iter.fromArray(Blob.toArray(item.valueAsBlob)));

        let result : Blob = Blob.fromArray(Iter.toArray(iter));
        return result;
    };

    /// Converts the WrappedBlobStore-Blob to the actual WrappedBlobStore type
    private func blob_to_WrappedBlobStoreItem(item : Blob) : WrappedBlobStoreItem {
        let blobArray = Blob.toArray(item);

        let totalBytes : Nat64 = Binary.LittleEndian.toNat64(Iter.toArray(Itertools.fromArraySlice(blobArray, 0, 8)));
        let nextAddress : Nat64 = Binary.LittleEndian.toNat64(Iter.toArray(Itertools.fromArraySlice(blobArray, 8, 16)));
        let previousAddress : Nat64 = Binary.LittleEndian.toNat64(Iter.toArray(Itertools.fromArraySlice(blobArray, 16, 24)));
        let valueAsBlobSize : Nat64 = Binary.LittleEndian.toNat64(Iter.toArray(Itertools.fromArraySlice(blobArray, 24, 32)));
        let valueAsBlob : Blob = Blob.fromArray(Iter.toArray(Itertools.fromArraySlice(blobArray, 32, 32 + Nat64.toNat(valueAsBlobSize))));

        let result : WrappedBlobStoreItem = {
            totalSize = totalBytes;

            nextAddress : Nat64 = nextAddress;

            previousAddress : Nat64 = previousAddress;

            //Size of the value-blob
            valueAsBlobSize : Nat64 = valueAsBlobSize;

            //The blob-content to store
            valueAsBlob : Blob = valueAsBlob;
        };
        return result;
    };

    //---------------------------------------------------------------------------------------------------------------------

    //----------------------------------------------------------------------------------------------------------
    // Keyinfo helpers:

    private func keyInfo_getTotalSize(keyInfoAddress : Nat64, item : MemoryStorage) : Nat64 {
        Region.loadNat64(item.memory_region.region, keyInfoAddress);
    };

    /// Update the first used index metadata in KeyInfo
    private func keyInfo_update_firstused_index(keyInfoAddress : Nat64, item : MemoryStorage, newfirstUsedIndex : Nat64) {
        Region.storeNat64(item.memory_region.region, keyInfoAddress + 16, newfirstUsedIndex);
    };

    /// Update the last used index metadata in KeyInfo
    private func keyInfo_update_lastused_index(keyInfoAddress : Nat64, item : MemoryStorage, newLastUsedIndex : Nat64) {
        Region.storeNat64(item.memory_region.region, keyInfoAddress + 24, newLastUsedIndex);
    };

    private func keyInfo_delete(key : Blob, keyInfoAddress : Nat64, item : MemoryStorage) {
        let keyInfoTotalSize = keyInfo_getTotalSize(keyInfoAddress, item);
        ignore MemoryRegion.removeBlob(item.memory_region, Nat64.toNat(keyInfoAddress), Nat64.toNat(keyInfoTotalSize));

        index_mapping_remove_value(key, item, keyInfoAddress);
    };

    // Convert KeyInfo type to blob
    private func keyInfo_to_blob(item : KeyInfo) : Blob {
        let blobSizeBytes : Nat64 = Nat64.fromNat(item.keyAsBlob.size());
        let totalBytes : Nat64 = blobSizeBytes + 32;
        let blob_totalSize : [Nat8] = Binary.LittleEndian.fromNat64(totalBytes);
        let blob_sizeOfKeyBlob : [Nat8] = Binary.LittleEndian.fromNat64(blobSizeBytes);
        let blob_firstUsedIndex : [Nat8] = Binary.LittleEndian.fromNat64(item.firstUsedIndex);
        let blob_lastUsedIndex : [Nat8] = Binary.LittleEndian.fromNat64(item.lastUsedIndex);

        var iter = Iter.fromArray(blob_totalSize);
        iter := Itertools.chain(iter, Iter.fromArray(blob_sizeOfKeyBlob));
        iter := Itertools.chain(iter, Iter.fromArray(blob_firstUsedIndex));
        iter := Itertools.chain(iter, Iter.fromArray(blob_lastUsedIndex));
        iter := Itertools.chain(iter, Iter.fromArray(Blob.toArray(item.keyAsBlob)));

        let result : Blob = Blob.fromArray(Iter.toArray(iter));
        return result;
    };

    // Convert back the Keyinfo-blob to KeyInfo type
    private func blob_to_keyInfo(item : Blob) : KeyInfo {
        let blobArray = Blob.toArray(item);
        let totalBytes : Nat64 = Binary.LittleEndian.toNat64(Iter.toArray(Itertools.fromArraySlice(blobArray, 0, 8)));
        let internalBlobSize : Nat64 = Binary.LittleEndian.toNat64(Iter.toArray(Itertools.fromArraySlice(blobArray, 8, 16)));
        let firstUsedIndex : Nat64 = Binary.LittleEndian.toNat64(Iter.toArray(Itertools.fromArraySlice(blobArray, 16, 24)));
        let lastUsedIndex : Nat64 = Binary.LittleEndian.toNat64(Iter.toArray(Itertools.fromArraySlice(blobArray, 24, 32)));
        let internalBlob : Blob = Blob.fromArray(Iter.toArray(Itertools.fromArraySlice(blobArray, 32, 32 + Nat64.toNat(internalBlobSize))));

        let result : KeyInfo = {
            totalSize : Nat64 = totalBytes;
            sizeOfKeyBlob : Nat64 = internalBlobSize;
            firstUsedIndex : Nat64 = firstUsedIndex;
            lastUsedIndex : Nat64 = lastUsedIndex;
            keyAsBlob : Blob = internalBlob;
        };
        return result;
    };

    private func get_KeyInfo_internal(address : Nat64, item : MemoryStorage) : ?KeyInfo {
        let sizeNeeded = Region.loadNat64(item.memory_region.region, address);
        let keyInfoBlob : Blob = MemoryRegion.loadBlob(item.memory_region, Nat64.toNat(address), Nat64.toNat(sizeNeeded));
        let resultOrNull : ?KeyInfo = Option.make(blob_to_keyInfo(keyInfoBlob));
        return resultOrNull;
    };

    private func get_KeyInfo(key : Blob, item : MemoryStorage) : (?KeyInfo, Nat64) {
        var keyHash : Nat32 = Blob.hash(key);
        var blobSize = Nat64.fromNat(key.size());
        let currentIndizesOrNull = StableTrieMap.get(item.index_mappings, Nat32.equal, nat32Identity, keyHash);

        switch (currentIndizesOrNull) {
            case (?indizesList) {
                let listSize : Nat = List.size(indizesList);
                if (listSize == 0) {
                    return (null, 0);
                };
                for (index in Iter.range(0, listSize -1)) {
                    let indexOrNull = List.get(indizesList, index);
                    switch (indexOrNull) {
                        case (?foundIndex) {
                            let keyInfoOrNull : ?KeyInfo = get_KeyInfo_internal(foundIndex, item);
                            switch (keyInfoOrNull) {
                                case (?keyInfo) {
                                    if (keyInfo.sizeOfKeyBlob == blobSize) {
                                        if (Blob.equal(keyInfo.keyAsBlob, key) == true) {
                                            return (keyInfoOrNull, foundIndex);
                                        };
                                    };
                                };
                                case (_) {
                                    //do nothing
                                };
                            };
                        };
                        case (_) {
                            // do nothing
                        };

                    };
                };

                //return Nat64.fromNat(List.size<Nat64>(indizesListItem));
            };
            case (_) {
                return (null, 0);
            };
        };

        return (null, 0);

    };

    private func get_default_keyInfo():KeyInfo{

        let result:KeyInfo = {
            totalSize : Nat64 = 0;
            sizeOfKeyBlob : Nat64=0;
            firstUsedIndex : Nat64=0;
            lastUsedIndex : Nat64=0;
            keyAsBlob : Blob = Blob.fromArray(Binary.LittleEndian.fromNat64(0));
        };
        return result;
    };

    //----------------------------------------------------------------------------------------------------------

    private func index_mapping_remove_value(key : Blob, item : MemoryStorage, valueToRemove : Nat64) {

        var keyHash : Nat32 = Blob.hash(key);
        let currentIndizesOrNull = StableTrieMap.get(item.index_mappings, Nat32.equal, nat32Identity, keyHash);
        switch (currentIndizesOrNull) {
            case (?listOfIndizes) {
                let newList = List.filter<Nat64>(listOfIndizes, func n { n != valueToRemove });
                if (List.size(newList) == 0) {
                    StableTrieMap.delete(item.index_mappings, Nat32.equal, nat32Identity, keyHash);
                } else {
                    StableTrieMap.put(item.index_mappings, Nat32.equal, nat32Identity, keyHash, newList);
                };
            };
            case (_) {
                StableTrieMap.delete(item.index_mappings, Nat32.equal, nat32Identity, keyHash);
            };
        };
    };

    private func nat32Identity(n : Nat32) : Nat32 { return n };






};
