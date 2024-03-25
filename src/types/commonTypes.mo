import KeyInfoTypes "keyInfo/keyInfoTypes";
import MemoryStorageTypes "memoryStorage/memoryStorageTypes";
import WrappedBlobTypes "wrappedBlob/wrappedBlobTypes";

module {

    // Identifiers:
    public let identifier_WrappedBlob : Nat64 = 144115188075855599;
    public let identifier_KeyInfo:Nat64 = 576460752303422881;

    public let version:Nat16 = 1;

    public type MemoryStorage = MemoryStorageTypes.MemoryStorage;

    // Offsets
    public let Offsets_KeyInfo = KeyInfoTypes.Offsets_KeyInfo;
    public let Offsets_WrappedBlob = WrappedBlobTypes.Offsets_WrappedBlob;

};
