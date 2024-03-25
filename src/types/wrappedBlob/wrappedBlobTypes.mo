import Nat64 "mo:base/Nat64";

module {

    /// Wrapper type as (linked list node) that holds the address for the actual value-blob
    /// and some meta-data.
    //  This type 'WrappedBlob' is never instantiated, and instead all the values are written directly into memory.
    public type WrappedBlob = {

        // identifier
        identifier : Nat64;

        // version
        version : Nat16;

        // Size of the value-blob in bytes
        internalBlobSize : Nat32;

        // The total allocated size in bytes for the wrapped-blob.
        // (This can be larger than 'internalBlobSize' if replace-buffer in 'memoryStorageTypes' was set > 0)
        internalBlobAllocatedSize : Nat32;

        // The internal blob is stored at this address
        internalBlobAddress : Nat64;
    };

    public let Offsets_WrappedBlob = {

        identifier : Nat64 = 0;
        version : Nat64 = 8;
        internalBlobSize : Nat64 = 10;
        internalBlobAllocatedSize : Nat64 = 14;
        internalBlobAddress : Nat64 = 18;

        bytesNeeded : Nat64 = 26; //  (8 + 2 + 4 + 4 + 8) == 26
    };

};
