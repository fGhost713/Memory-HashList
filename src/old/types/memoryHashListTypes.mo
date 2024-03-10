import { MemoryRegion } "mo:memory-region";
import StableTrieMap "mo:StableTrieMap";
import List "mo:base/List";
import Nat64 "mo:base/Nat64";
import Nat32 "mo:base/Nat32";

module{

    public type MemoryStorage = {

        //The used memory region
        memory_region : MemoryRegion.MemoryRegion;

        // The start-indizes for key (as Nat32)
        // There might be more indizies in case of hash-collision (== same Nat32 hashed key) therefore the value as List.
        index_mappings : StableTrieMap.StableTrieMap<Nat32, List.List<Nat64>>;
    };

    /// The complete key as blob is stored here (So we can compare it, in case of hash-collision),
    /// and also the first-and last used index for the memory-adresses, where the actual blob is stored.
    public type KeyInfo = {

        // The totalsize in bytes used for this type
        totalSize : Nat64;

        // Nice to have for upgrade scenarios
        //versionNumber:Int32;

        // The size of the blob 'keyAsBlob' in bytes
        sizeOfKeyBlob : Nat64;

        // The first used Item-Index (=address for the actual stored blob-value)
        firstUsedIndex : Nat64;

        // Store the last used item-index here, so that append new values will be fast, because we have index of last item
        lastUsedIndex : Nat64;

        // The used key as blob
        keyAsBlob : Blob;

    };

    public type Index100Table = {


    };

    /// Wrapper type  that holds the actual blob and some meta-data
    public type WrappedBlobStoreItem = {

        //The size of this instance.
        totalSize : Nat64;

        //Index for next item
        nextAddress : Nat64;

        //Index for the previous item
        previousAddress : Nat64;

        //Size of the value-blob
        valueAsBlobSize : Nat64;

        //The blob-content to store
        valueAsBlob : Blob;

        // Bytes reserved. If the internal blob should be replaced
        // and the size of new blob is not bigger than initialblob-size + 8 bytes 
        // then the internal blob can be replaced. If not then we need to create new 
        // 'WrappedBlobStoreItem' and store the new blob there.
        //replaceBuffer:Nat64;
    };


};