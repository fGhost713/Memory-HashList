import CommonMemoryHashKeyList "Helpers/commonMemoryHashKeyList";
import Option "mo:base/Option";

module MemoryHashList{

    public func get_new_memory_storage() : CommonMemoryHashKeyList.MemoryStorage {
        CommonMemoryHashKeyList.get_new_memory_storage();
    };

    public func show_memory_used(item : CommonMemoryHashKeyList.MemoryStorage): (Text){
        CommonMemoryHashKeyList.show_memory_used(item);
    };

    public func put(key : Blob, item : CommonMemoryHashKeyList.MemoryStorage, blobToStore : Blob) {
        CommonMemoryHashKeyList.singleBlob_put(key, item, blobToStore);
    };

    public func delete(key : Blob, item : CommonMemoryHashKeyList.MemoryStorage) {
        CommonMemoryHashKeyList.singleBlob_delete(key, item);
    };

    public func get(key : Blob, item : CommonMemoryHashKeyList.MemoryStorage) : ?Blob {
        CommonMemoryHashKeyList.singleBlob_get(key, item);
    };

};
