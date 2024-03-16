import { MemoryRegion } "mo:memory-region";
import StableTrieMap "mo:StableTrieMap";
import List "mo:base/List";
import Nat64 "mo:base/Nat64";
import Nat32 "mo:base/Nat32";
import Nat16 "mo:base/Nat16";
import Nat8 "mo:base/Nat8";



module{


    /// Wrapper type as (linked list node) that holds the actual value-blob and some meta-data
    public type WrappedBlob = {

        // The size of this instance in bytes.
        totalSize : Nat64;

        identifier:Nat64;

        // Index for next item
        addressOfNextItem : Nat64;

        // Index for the previous item
        addressOfPreviousItem : Nat64;

        // Size of the value-blob in bytes
        internalBlobSize : Nat64;

        // The blob-content to store
        internalBlob : Blob;
    };

    public let Offsets_WrappedBlob = {
      
        totalSize : Nat64 = 0;
        identifier:Nat64 = 8;
        addressOfNextItem : Nat64 = 16;
        addressOfPreviousItem : Nat64 = 24;
        internalBlobSize : Nat64 = 32;
        internalBlob : Nat64 = 40;

        minimumBytesNeeded:Nat64 = 48;
    };

};