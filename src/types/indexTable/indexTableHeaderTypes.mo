module {

    public type IndexTableHeader = {
        identifier : Nat64;
        totalEntriesCount : Nat64;

        addressOfFirstWrappedBlob:Nat64;
        addressOfLastWrappedBlob:Nat64;

        startMainIndexTable : Nat64;
        endMainIndexTable : Nat64;

        startFirstParentIndexTable : Nat64;
        endFirstParentIndexTable : Nat64;

        startLastParentIndexTable : Nat64;
        endLastParentIndexTable : Nat64;
    };

    public let Offsets_IndexTableHeader = {

        identifier : Nat64 = 0;
        totalEntriesCount : Nat64 = 8;

        addressOfFirstWrappedBlob:Nat64 = 8;
        addressOfLastWrappedBlob:Nat64 = 16;

        startMainIndexTable : Nat64 = 24;
        endMainIndexTable : Nat64 = 32;

        startFirstParentIndexTable : Nat64 = 40;
        endFirstParentIndexTable : Nat64 = 48;

        startLastParentIndexTable : Nat64 = 56;
        endLastParentIndexTable : Nat64 = 72;
       
        bytesNeeded : Nat64 = 80;
    };

    // public type ParentIndexTableHeader = {
    //     identifier : Nat64;
    //     parentTablesCount : Nat64;
    // };

    // public let Offset_ParentIndexTableHeader = {
    //     identifier : Nat64 = 0;
    //     parentTablesCount : Nat64 = 8;
    // };

};
