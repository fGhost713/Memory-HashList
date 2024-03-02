import CommonMemoryHashKeyList "helpers/commonMemoryHashKeyList";
import Result "mo:base/Result";

module MemoryMultiHashList{

    public func get_new_memory_storage() : CommonMemoryHashKeyList.MemoryStorage {
        CommonMemoryHashKeyList.get_new_memory_storage();
    };

    public func show_memory_used(item : CommonMemoryHashKeyList.MemoryStorage): (Text){
        CommonMemoryHashKeyList.show_memory_used(item);
    };

    public func append(key : Blob, item : CommonMemoryHashKeyList.MemoryStorage, blobToStore : Blob): (Nat64 /* keyInfo address*/, Nat64 /*stored blob address*/)  {
        CommonMemoryHashKeyList.multiBlob_append(key, item, blobToStore);
    };

    public func get_all_memory_addresses(key : Blob, item : CommonMemoryHashKeyList.MemoryStorage) : [Nat64] {
        CommonMemoryHashKeyList.multiBlob_GetAllAddresses(key,item);
    };

    public func get_by_memory_address(key : Blob, item : CommonMemoryHashKeyList.MemoryStorage, address : Nat64) : ?Blob {
        CommonMemoryHashKeyList.multiBlob_GetBlob_by_address(key, item, address);
    };

    public func get_by_index(key : Blob, item : CommonMemoryHashKeyList.MemoryStorage, index : Nat64) : ?Blob {
        CommonMemoryHashKeyList.multiBlob_GetBlob_by_index(key, item, index);
    };

     public func get_by_index_and_count(key : Blob, item : CommonMemoryHashKeyList.MemoryStorage, index : Nat64, count:Nat64) : [Blob] {
        CommonMemoryHashKeyList.multiBlob_GetBlobs_by_index_and_count(key, item, index, count);
    };

    public func get_all(key : Blob, item : CommonMemoryHashKeyList.MemoryStorage) : [Blob] {
        CommonMemoryHashKeyList.multiBlob_GetAllBlobs(key, item);
    };

    public func get_all_with_adresses(key : Blob, item : CommonMemoryHashKeyList.MemoryStorage) : [(Blob, Nat64 /*address*/)] {
        CommonMemoryHashKeyList.multiBlob_GetAllBlobsWithAdresses(key, item);
    };

    public func delete(key : Blob, item : CommonMemoryHashKeyList.MemoryStorage, address : Nat64):Result.Result<Blob,Text> {
        CommonMemoryHashKeyList.multiBlob_delete(key, item, address);
    };

    public func delete_all(key : Blob, item : CommonMemoryHashKeyList.MemoryStorage) {
        CommonMemoryHashKeyList.multiBlob_delete_all(key, item);
    };

};
