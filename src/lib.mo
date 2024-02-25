import MemoryHashListType "memoryHashList";
import MemoryMultiHashListType "memoryMultiHashList";
import CommonMemoryHashKeyList "/Helpers/commonMemoryHashKeyList";
import BlobifyModule "mo:memory-buffer/Blobify";

module {

    public func getNewMemoryStorage() : CommonMemoryHashKeyList.MemoryStorage {
        CommonMemoryHashKeyList.getNewMemoryStorage();
    };

    public let MemoryHashList = MemoryHashListType;
    public let MemoryMultiHashList = MemoryMultiHashListType;
    public let Blobify = BlobifyModule;
  
};
