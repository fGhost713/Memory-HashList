import CommonMemoryHashKeyList "Helpers/commonMemoryHashKeyList";

module {

    public func getNewMemoryStorage() : CommonMemoryHashKeyList.MemoryStorage {
        CommonMemoryHashKeyList.getNewMemoryStorage();
    };

    public func put(key : Blob, item : MemoryStorage, blobToStore : Blob) {
        CommonMemoryHashKeyList.singleBlob_put(key, item, blobToStore);
    };

    public func delete(key : Blob, item : MemoryStorage) {
        CommonMemoryHashKeyList.singleBlob_delete(key, item);
    };

    public func get(key : Blob, item : MemoryStorage) : ?Blob {
        CommonMemoryHashKeyList.singleBlob_get(key, item);
    };

};
