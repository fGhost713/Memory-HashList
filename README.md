
# Memory-HashList #



## Description: ##


 The purpose of this module is for storing multiple values per key into memory.

 The value and the key are blob-types.

 For each key and each value some overhead is added into heap-memory:
 - The average overhead for each added key is estimated 180 bits
 - The average overhead for each value is estimated 64 bits

 The actual blobs for the key and value is stored in the memory-region. (not heap memory)
 

 Please note:
 Getting the blob for at a specified index is now fast,but the functions insert_at_index and remove_at_index are at the moment incredible slow (required much cycles - see benchmark results at the end of this readme text) and should only be used if not much values were added to the key.



## Installation of this package ##

(1) First install mops package manager:

        sudo npm i -g ic-mops

(2) Now we need to init mops

        mops init


(3) Now you need to install the Memory-HashList module:

    mops add memory-hashlist



 ## Example usages ##

 ### Usage with class or stable is possible ###

    import lib "memory-hashlist";
    import Blob "mo:base/Blob";
    import Text "mo:base/Text";


    actor{
    
        // here the replacement-buffer is set to 8 in the constructor
        stable var mem = lib.get_new_memory_storage(8);

        let key:Blob = lib.Blobify.Text.to_blob("key1");
        let blobValue:Blob = lib.Blobify.Text.to_blob("myBlob");


        // ***************************************************
        // use as class

        // initializing the hashList with class usage    
        let hashList = lib.MemoryHashList(mem);

        // add one value                        
        ignore hashList.add(key, blobValue);
        
        // ***************************************************

        // ***************************************************
        // use as stable:

        lib.StableMemoryHashList.add(mem, key, blobValue);

        // ***************************************************
    };


 ### Available functions ###
    

    // Adding many blobs at once
    public func add_many(key : Blob, values: [Blob]) 

    // adding new value for specified key (if key is not existing it is created)
    public func add(key : Blob, value : Blob) 
    : (Nat /*index*/, Nat64 /* wrapped-blob address*/)
    
    // Returns all the used keys (as blob)
    public func get_all_keys() 
    : [Blob] 
    
    // Overwrites the existing blob at specified index
    public func update_at_index(key : Blob, index : Nat, newBlob : Blob) 
    : Bool
    
    // Insert many blobs at index
    public func insert_many_at_index(key : Blob, index : Nat, blobs : [Blob]) 
    : Result.Result<Text, Text> 
        
    // Insert blob-value at index
    public func insert_at_index(key : Blob, index : Nat, newBlob : Blob) 
    : Result.Result<Nat64, Text> 

    // Removes values for the key from 'firstIndex' to 'lastIndex'
    public func remove_at_range(key : Blob, startIndex : Nat, lastIndexOrNull : ?Nat) 
    : Result.Result<Text, Text> 
    
    // Removes value for the key at specific index position
    public func remove_at_index(key : Blob, index : Nat) 
    : Result.Result<Text, Text> 

    // removes the key and all the added values to this key
    public func remove_key(key : Blob) 
    : Bool 

    // return blob from index
    public func get_at_index(key : Blob, innerIndex : Nat) 
    : ?Blob 

    // return multiply blob's from index 'firstIndex' to the index 'lastIndex'
    public func get_at_range(key : Blob, firstIndex : Nat, lastIndex : Nat) 
    : [?Blob]

    // return last index or null if empty
    public func get_last_index(key : Blob) 
    : ?Nat
    
 ### Benchmark ###


    Add new items benchmark


    Instructions

    |                                             |      1 |      10 |     100 |      1000 |      10000 |
    | :------------------------------------------ | -----: | ------: | ------: | --------: | ---------: |
    | Adding new items (each blob-size 35 bytes)  | 18_030 | 103_673 | 910_033 | 8_942_751 | 88_251_405 |
    | Adding new items (each blob-size 400 bytes) | 18_687 | 105_477 | 920_032 | 9_108_829 | 92_066_494 |


    Heap

    |                                             |   1 |  10 |   100 |  1000 |  10000 |
    | :------------------------------------------ | --: | --: | ----: | ----: | -----: |
    | Adding new items (each blob-size 35 bytes)  | 432 | 528 | 1_060 | 5_232 | 43_520 |
    | Adding new items (each blob-size 400 bytes) | 396 | 504 | 1_056 | 5_324 | 43_504 |


    ——————————————————————————————————————————————————



    Get at index benchmark.


    Instructions

    |              |     1 |     10 |     100 |      1000 |      10000 |
    | :----------- | ----: | -----: | ------: | --------: | ---------: |
    | Get at index | 6_173 | 50_963 | 496_622 | 4_951_157 | 49_493_770 |


    Heap

    |              |   1 |  10 | 100 | 1000 | 10000 |
    | :----------- | --: | --: | --: | ---: | ----: |
    | Get at index | 228 | 228 | 228 |  228 |   228 |


    ——————————————————————————————————————————————————



    Insert at index -  benchmark. (slow)


    Instructions

    |                              |      1 |      10 |        100 |        1000 |          2000 |
    | :--------------------------- | -----: | ------: | ---------: | ----------: | ------------: |
    | Insert value at first index  | 17_480 | 211_922 | 10_491_264 | 946_527_187 | 3_765_145_423 |
    | Insert value at middle index |  9_171 | 166_161 |  5_834_138 | 479_259_485 | 1_896_108_597 |
    | Insert value at end index    | 19_542 | 128_339 |  1_206_271 |  11_583_097 |    23_606_882 |


    Heap

    |                              |   1 |  10 | 100 |  1000 |  2000 |
    | :--------------------------- | --: | --: | --: | ----: | ----: |
    | Insert value at first index  | 244 | 292 | 740 | 4_580 | 8_712 |
    | Insert value at middle index | 228 | 292 | 740 | 4_580 | 8_712 |
    | Insert value at end index    | 244 | 292 | 740 | 4_580 | 8_676 |


    ——————————————————————————————————————————————————



    Remove at index - benchmark. (slow)


    Instructions

    |                              |      1 |      10 |       100 |        1000 |          2000 |
    | :--------------------------- | -----: | ------: | --------: | ----------: | ------------: |
    | Remove value at first index  | 31_048 | 208_244 | 4_967_804 | 319_232_127 | 1_233_713_789 |
    | Remove value at middle index | 54_038 | 345_081 | 4_532_440 | 177_738_490 |   651_362_333 |
    | Remove value at end index    | 60_904 | 370_915 | 3_209_385 |  30_774_695 |    52_541_083 |


    Heap

    |                              |   1 |   10 |    100 |    1000 |    2000 |
    | :--------------------------- | --: | ---: | -----: | ------: | ------: |
    | Remove value at first index  | 108 |  204 |  2_684 |  26_784 |  54_336 |
    | Remove value at middle index | 128 |  -48 |   -532 |  -4_668 |  -9_060 |
    | Remove value at end index    | 128 | -376 | -3_924 | -36_168 | -71_852 |


    ——————————————————————————————————————————————————



    Remove key benchmark.


    Instructions

    |            |      1 |      10 |     100 |      1000 |      10000 |
    | :--------- | -----: | ------: | ------: | --------: | ---------: |
    | Remove key | 23_495 | 108_530 | 938_465 | 9_239_064 | 92_253_809 |


    Heap

    |            |   1 | 10 |  100 |   1000 |   10000 |
    | :--------- | --: | -: | ---: | -----: | ------: |
    | Remove key | 176 | 28 | -496 | -4_708 | -42_932 |


    ——————————————————————————————————————————————————


    Update value at index benchmark


    Instructions

    |                       |     1 |     10 |     100 |      1000 |      10000 |
    | :-------------------- | ----: | -----: | ------: | --------: | ---------: |
    | Update value at index | 5_541 | 59_321 | 548_903 | 5_363_191 | 51_575_545 |


    Heap

    |                       |   1 |  10 | 100 | 1000 | 10000 |
    | :-------------------- | --: | --: | --: | ---: | ----: |
    | Update value at index | 228 | 228 | 228 |  228 |   228 |


    ——————————————————————————————————————————————————



    Update value at index with fallback to put benchmark.


    Instructions

    |                                            |     1 |      10 |       100 |       1000 |       10000 |
    | :----------------------------------------- | ----: | ------: | --------: | ---------: | ----------: |
    | Update value at index with fallback to put | 5_541 | 107_346 | 1_302_038 | 14_815_640 | 162_194_728 |


    Heap

    |                                            |   1 |  10 |   100 |   1000 |   10000 |
    | :----------------------------------------- | --: | --: | ----: | -----: | ------: |
    | Update value at index with fallback to put | 228 | 388 | 3_408 | 31_704 | 317_020 |

