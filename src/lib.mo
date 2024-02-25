import MemoryHashListType "memoryHashList";
import MemoryMultiHashListType "memoryMultiHashList";
import CommonMemoryHashKeyList "/Helpers/commonMemoryHashKeyList";
import Mem  "mo:memory-region";

module {

    public func getNewMemoryStorage() : CommonMemoryHashKeyList.MemoryStorage {
        CommonMemoryHashKeyList.getNewMemoryStorage();
    };

    public let MemoryHashList = MemoryHashListType;
    public let MemoryMultiHashList = MemoryMultiHashListType;
    public let MemoryRegion = Mem;
};
