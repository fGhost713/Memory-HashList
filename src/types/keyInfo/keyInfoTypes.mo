

module {

    /// The complete key as blob is stored here (So we can compare it, in case of hash-collision),
    public type KeyInfo = {

        // The totalsize in bytes used for this type
        totalSize : Nat64;

        // The type identifier
        identifier:Nat64;

        // The size of the blob 'keyAsBlob' in bytes
        sizeOfKeyBlob: Nat64;

        // Address of the table header for access with index
        addressOfIndexTableHeader: Nat64;

        // Address of the table header for access with associated key
        addressOfAssociatedKeyTableHeader:Nat64; 

        // The used key as blob
        keyAsBlob : Blob;

    };
    
    public let Offsets_KeyInfo = {
        totalSize : Nat64 = 0;
        identifier:Nat64 = 8;
        sizeOfKeyBlob: Nat64 = 16;
        addressOfIndexTableHeader: Nat64 = 24;
        addressOfAssociatedKeyTableHeader:Nat64 = 32; 
        keyAsBlob : Nat64 = 40;

        minBytesNeeded:Nat64 = 40;
    };

};