import { MemoryRegion } "mo:memory-region";
import StableTrieMap "mo:StableTrieMap";
import List "mo:base/List";
import Nat64 "mo:base/Nat64";
import Nat32 "mo:base/Nat32";
import Nat16 "mo:base/Nat16";

module {

    public type MemoryStorage = {

        //The used memory region
        memory_region : MemoryRegion.MemoryRegion;

        // The start-indizes for key (as Nat32)
        // There might be more indizies in case of hash-collision (== same Nat32 hashed key) therefore the value as List.
        index_mappings : StableTrieMap.StableTrieMap<Nat32, List.List<Nat64>>;

        // The replace buffer size
        // If value update method is called and the new blob is not bigger than the initial-blob-size + replaceBufferSize
        // then the existing memory-address can be used, else new memory address would be allocated and old memory-address freed.
        replaceBufferSize:Nat64;

        // The dummy array with size of replaceBufferSize
        replaceBufferAsBlob:[Nat8]
    };

    /// The complete key as blob is stored here (So we can compare it, in case of hash-collision),
    /// and also the first-and last used index for the memory-adresses, where the actual blob is stored.
    public type KeyInfo = {

        // The totalsize in bytes used for this type
        totalSize : Nat64;

        // The size of the blob 'keyAsBlob' in bytes
        sizeOfKeyBlob : Nat64;

        valueItemsCount:Nat64;

        addressOfFirstUsedWrappedBlob:Nat64;

        addressOfLastUsedWrappedBlob:Nat64;

        addressOfIndexTableStep100: Nat64;

        addressOfIndexTableStep1000: Nat64;

        addressOfIndexTableStep10000 : Nat64;

        // The used key as blob
        keyAsBlob : Blob;

    };


    public type StepIndexBucket = {

        bucketTotalSize:Nat64;
        bucketIdentifier:Nat64; //all buckets will have same identifier,so wie know memory place not empty, but real bucket available
        bucketItemsCount:Nat64;
    };

    /// Wrapper type as (linked list node) that holds the actual value-blob and some meta-data
    public type WrappedBlob = {

        //The size of this instance in bytes.
        totalSize : Nat64;

        wrappedBlobIdentifier:Nat64;

        //Index for next item
        addressOfNextItem : Nat64;

        //Index for the previous item
        addressOfPreviousItem : Nat64;

        //Size of the value-blob in bytes
        internalBlobSize : Nat64;

        //The blob-content to store
        internalBlob : Blob;
    };

};
