import { MemoryRegion } "mo:memory-region";
import StableTrieMap "mo:StableTrieMap";
import List "mo:base/List";
import Nat64 "mo:base/Nat64";
import Nat32 "mo:base/Nat32";
import Nat16 "mo:base/Nat16";
import Nat8 "mo:base/Nat8";



module{


    /// Wrapper type as (linked list node) that holds the address for the actual value-blob 
    /// and some meta-data.
    //  This type 'WrappedBlob' is never instantiated, and instead all the values are written directly into memory.
    public type WrappedBlob = {

        // Index for next item
        addressOfNextItem : Nat64;

        // Index for the previous item
        addressOfPreviousItem : Nat64;

        // Size of the value-blob in bytes
        internalBlobSize : Nat64;

        // The total allocated size in bytes for the wrapped-blob.
        // (This can be larger than 'internalBlobSize' if replace-buffer in 'memoryStorageTypes' was set > 0)
        internalBlobAllocatedSize:Nat64;

        // The internal blob is stored at this address
        internalBlobAddress : Nat64;
    };

    public let Offsets_WrappedBlob = {
      
        addressOfNextItem : Nat64 = 0;
        addressOfPreviousItem : Nat64 = 8;
        internalBlobSize : Nat64 = 16;
        internalBlobAllocatedSize:Nat64 = 24;
        internalBlobAddress : Nat64 = 32;

        bytesNeeded:Nat64 = 40; // 5 * 8 bytes
    };

};