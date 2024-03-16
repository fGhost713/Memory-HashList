

module{

    public type IndexTable = {
         
        identifier:Nat64;

        // number of entry-rows used in this table
        entriesCount:Nat64;

        // sum of all items-count in this table
        sumOfItemsCount:Nat64;

        // Address of corresponding parent-table
        parentTable:Nat64;

        // The corresponding index inside the parent-table
        parentTableIndex:Nat64;

        // Address of next index-table
        nextIndexTable:Nat64;

        // Address of previous index-table
        previousIndexTable:Nat64;
    };

       public let Offset_IndexTable = {
         
        identifier:Nat64 = 0;

        entriesCount:Nat64 = 8;

        sumOfItemsCount:Nat64 = 16;

        // Address of corresponding parent-table
        parentTable:Nat64 = 24;

        // The corresponding index inside the parent-table
        parentTableIndex:Nat64 = 32;

        // Address of next index-table
        nextIndexTable:Nat64 = 40;

        // Address of previous index-table
        previousIndexTable:Nat64 = 48;

        minSize:Nat64 = 56;

    };


   



  





};