import Nat64 "mo:base/Nat64";
import KeyInfoTypes "keyInfo/keyInfoTypes";
import MemoryStorageTypes "memoryStorage/memoryStorageTypes";
import WrappedBlobTypes "wrappedBlob/wrappedBlobTypes";

module {

  
    public type MemoryStorage = MemoryStorageTypes.MemoryStorage;

    // Offsets
    public let Offsets_KeyInfo = KeyInfoTypes.Offsets_KeyInfo;
    public let Offsets_WrappedBlob = WrappedBlobTypes.Offsets_WrappedBlob;


};
