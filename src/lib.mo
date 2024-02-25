import MemoryHashListType "memoryHashList";
import MemoryMultiHashListType "memoryMultiHashList";
import CommonMemoryHashKeyList "/Helpers/commonMemoryHashKeyList";
import BlobifyModule "mo:memory-buffer/Blobify";

module {

    public func get_new_memory_storage() : CommonMemoryHashKeyList.MemoryStorage {
        CommonMemoryHashKeyList.get_new_memory_storage();
    };

    public let MemoryHashList = MemoryHashListType;
    public let MemoryMultiHashList = MemoryMultiHashListType;
    public let Blobify = BlobifyModule;
  
};
