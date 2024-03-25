module {

    /// The complete key as blob is stored here (So we can compare it, in case of hash-collision),
    public type KeyInfo = {

        // The totalsize in bytes used for this type
        totalSize : Nat32;

        identifier:Nat64;

        version:Nat16;

        // The related vector-index
        vectorIndex : Nat64;

        // The size of the blob 'keyAsBlob' in bytes
        sizeOfKeyBlob : Nat32;

        // The used key as blob
        keyAsBlob : Blob;

    };

    public let Offsets_KeyInfo = {
        totalSize : Nat64 = 0;
        identifier: Nat64 = 4;
        version: Nat64 =  12;
        vectorIndex : Nat64 = 14;
        sizeOfKeyBlob : Nat64 = 22;
        keyAsBlob : Nat64 = 26;

        minBytesNeeded : Nat64 = 28; // 4 + 8 + 2 + 8 + 4
    };

};
