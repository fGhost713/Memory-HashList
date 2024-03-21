

module {

    /// The complete key as blob is stored here (So we can compare it, in case of hash-collision),
    public type KeyInfo = {

        // The totalsize in bytes used for this type
        totalSize : Nat64;

        // The related vector-index
        vectorIndex:Nat64;

        // The size of the blob 'keyAsBlob' in bytes
        sizeOfKeyBlob: Nat64;

        // The used key as blob
        keyAsBlob : Blob;

    };
    
    public let Offsets_KeyInfo = {
        totalSize : Nat64 = 0;
        vectorIndex:Nat64 = 8;
        sizeOfKeyBlob: Nat64 = 16;
        keyAsBlob : Nat64 = 24;

        minBytesNeeded:Nat64 = 24;
    };

};