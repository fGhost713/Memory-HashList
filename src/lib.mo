import MemoryHashListType "memoryHashList";
import MemoryMultiHashListType "memoryMultiHashList";
import CommonMemoryHashKeyList "/helpers/commonMemoryHashKeyList";
import BlobifyModule "mo:memory-buffer/Blobify";

module MemoryHashListLib {

    public func get_new_memory_storage() : CommonMemoryHashKeyList.MemoryStorage {
        CommonMemoryHashKeyList.get_new_memory_storage();
    };

    public let MemoryHashList = MemoryHashListType;
    public let MemoryMultiHashList = MemoryMultiHashListType;
    public let Blobify = BlobifyModule;
  
};
