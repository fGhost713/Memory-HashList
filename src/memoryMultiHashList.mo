import CommonMemoryHashKeyList "Helpers/commonMemoryHashKeyList";

module {

    public func getNewMemoryStorage() : CommonMemoryHashKeyList.MemoryStorage {
        CommonMemoryHashKeyList.getNewMemoryStorage();
    };

    public func append(key : Blob, item : MemoryStorage, blobToStore : Blob) {
        CommonMemoryHashKeyList.multiBlob_append(key, item, blobToStore);
    };

    public func multiBlob_GetAllAddresses(key : Blob, item : MemoryStorage) : [Nat64] {
        CommonMemoryHashKeyList.multiBlob_GetAllAddresses(key,item);
    };

    public func multiBlob_GetBlob(item : MemoryStorage, address : Nat64) : Blob {
        CommonMemoryHashKeyList.multiBlob_GetBlob(item, address);

    };

    public func multiBlob_GetAllBlobs(key : Blob, item : MemoryStorage) : [Blob] {
        CommonMemoryHashKeyList.multiBlob_GetAllBlobs(key, item);
    };

    public func multiBlob_GetAllBlobsWithAdresses(key : Blob, item : MemoryStorage) : [(Blob, Nat64 /*address*/)] {
        CommonMemoryHashKeyList.multiBlob_GetAllBlobsWithAdresses(key, item);
    };

    public func multiBlob_delete(key : Blob, item : MemoryStorage, address : Nat64) {
        CommonMemoryHashKeyList.multiBlob_delete(key, item, address);
    };

    public func multiBlob_delete_all(key : Blob, item : MemoryStorage) {
        CommonMemoryHashKeyList.multiBlob_delete_all(key, item);
    };

};
