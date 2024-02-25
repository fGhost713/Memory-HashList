import CommonMemoryHashKeyList "Helpers/commonMemoryHashKeyList";
import Result "mo:base/Result";

module MemoryMultiHashList{

    public func getNewMemoryStorage() : CommonMemoryHashKeyList.MemoryStorage {
        CommonMemoryHashKeyList.getNewMemoryStorage();
    };

    public func append(key : Blob, item : CommonMemoryHashKeyList.MemoryStorage, blobToStore : Blob): (Nat64 /* keyInfo address*/, Nat64 /*stored blob address*/)  {
        CommonMemoryHashKeyList.multiBlob_append(key, item, blobToStore);
    };

    public func getAllAddresses(key : Blob, item : CommonMemoryHashKeyList.MemoryStorage) : [Nat64] {
        CommonMemoryHashKeyList.multiBlob_GetAllAddresses(key,item);
    };

    public func get(key : Blob, item : CommonMemoryHashKeyList.MemoryStorage, address : Nat64) : ?Blob {
        CommonMemoryHashKeyList.multiBlob_GetBlob(key, item, address);
    };

    public func get_all(key : Blob, item : CommonMemoryHashKeyList.MemoryStorage) : [Blob] {
        CommonMemoryHashKeyList.multiBlob_GetAllBlobs(key, item);
    };

    public func get_all_WithAdresses(key : Blob, item : CommonMemoryHashKeyList.MemoryStorage) : [(Blob, Nat64 /*address*/)] {
        CommonMemoryHashKeyList.multiBlob_GetAllBlobsWithAdresses(key, item);
    };

    public func delete(key : Blob, item : CommonMemoryHashKeyList.MemoryStorage, address : Nat64):Result.Result<Blob,Text> {
        CommonMemoryHashKeyList.multiBlob_delete(key, item, address);
    };

    public func delete_all(key : Blob, item : CommonMemoryHashKeyList.MemoryStorage) {
        CommonMemoryHashKeyList.multiBlob_delete_all(key, item);
    };

};
