import Bool "mo:base/Bool";
import Nat64 "mo:base/Nat64";

module{
  public type TableUpdateInfo = {
        isNewTable:Bool;
        ownAddress:Nat64;
        prevTableAddress:Nat64;
        sumOfAllItemsCount:Nat64;
        usedIndex:Nat64;
    };

    
};