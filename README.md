
# Memory-HashList #

 </br>

## Description: ##

</br>
 The purpose of this module is for storing values into memory and access them by key.</br>
 The value and the key are blob-types.
 </br></br>
 Two modules are available for that purpose. (MemoryHashList and MemoryMultiHashList)</br></br>


## Installation of this package ##

(1) First install mops package manager: </br>

        sudo npm i -g ic-mops

(2) Now we need to init mops

        mops init


(3) Now you need to install the Memory-HashList module:

    mops add memory-hashlist

</br>

 ## Example usages ##

 ### 1. MemoryHashList </br> ###
    
Here we can store exactly one value per key.</br>
Available functions:</br>

    module MemoryHashList{

        public func get_new_memory_storage() : CommonMemoryHashKeyList.MemoryStorage {
            CommonMemoryHashKeyList.get_new_memory_storage();
        };

        public func show_memory_used(item : CommonMemoryHashKeyList.MemoryStorage): (Text){
            CommonMemoryHashKeyList.show_memory_used(item);
        };

        public func put(key : Blob, item : CommonMemoryHashKeyList.MemoryStorage, blobToStore : Blob) {
            CommonMemoryHashKeyList.singleBlob_put(key, item, blobToStore);
        };

        public func delete(key : Blob, item : CommonMemoryHashKeyList.MemoryStorage) {
            CommonMemoryHashKeyList.singleBlob_delete(key, item);
        };

        public func get(key : Blob, item : CommonMemoryHashKeyList.MemoryStorage) : ?Blob {
            CommonMemoryHashKeyList.singleBlob_get(key, item);
        };

    };

Example:</br>

    import lib "mo:Memory-HashList";
    import Blob "mo:base/Blob";
    import Text "mo:base/Text";

    actor {
      public query func singleBlob_usage_example() : async () {

        // (1) Create and get new memory_storage (should be used as stable var in production)

        let memoryStore = lib.get_new_memory_storage();
        let mem = lib.MemoryHashList;


        // (2) Create key and value that should be stored

        let key1 : Blob = lib.Blobify.Text.to_blob("key1");
        let blob1 : Blob = lib.Blobify.Text.to_blob("hello");


        // (3) Store the blob into memory

        mem.put(key1, memoryStore, blob1);


        // (4) Get the stored value from memory

        let storedBlob : ?Blob = mem.get(key1, memoryStore);


        // (5) Convert the block to Text

        var storedText : Text = "";
        switch (storedBlob) {
            case (?blob) {
                storedText := lib.Blobify.Text.from_blob(blob);
            };
            case (_) {
                // do nothing
            };
        };


        // (6) Delete an entry:

        mem.delete(key1, memoryStore);
      };
    };



 ### 1. MemoryMultiHashList </br> ###
Here we can store multiple values per key.</br>
Available functions: </br>



    module MemoryMultiHashList{

        public func get_new_memory_storage() : CommonMemoryHashKeyList.MemoryStorage {
            CommonMemoryHashKeyList.get_new_memory_storage();
        };

        public func show_memory_used(item : CommonMemoryHashKeyList.MemoryStorage): (Text){
            CommonMemoryHashKeyList.show_memory_used(item);
        };

        public func append(key : Blob, item : CommonMemoryHashKeyList.MemoryStorage, blobToStore : Blob): (Nat64 /* keyInfo address*/, Nat64 /*stored blob address*/)  {
            CommonMemoryHashKeyList.multiBlob_append(key, item, blobToStore);
        };

        public func get_all_memory_addresses(key : Blob, item : CommonMemoryHashKeyList.MemoryStorage) : [Nat64] {
            CommonMemoryHashKeyList.multiBlob_GetAllAddresses(key,item);
        };

        public func get_by_memory_address(key : Blob, item : CommonMemoryHashKeyList.MemoryStorage, address : Nat64) : ?Blob {
            CommonMemoryHashKeyList.multiBlob_GetBlob_by_address(key, item, address);
        };

        public func get_by_index(key : Blob, item : CommonMemoryHashKeyList.MemoryStorage, index : Nat64) : ?Blob {
            CommonMemoryHashKeyList.multiBlob_GetBlob_by_index(key, item, index);
        };

        public func get_by_index_and_count(key : Blob, item : CommonMemoryHashKeyList.MemoryStorage, index : Nat64, count:Nat64) : [Blob] {
            CommonMemoryHashKeyList.multiBlob_GetBlobs_by_index_and_count(key, item, index, count);
        };

        public func get_all(key : Blob, item : CommonMemoryHashKeyList.MemoryStorage) : [Blob] {
            CommonMemoryHashKeyList.multiBlob_GetAllBlobs(key, item);
        };

        public func get_all_with_adresses(key : Blob, item : CommonMemoryHashKeyList.MemoryStorage) : [(Blob, Nat64 /*address*/)] {
            CommonMemoryHashKeyList.multiBlob_GetAllBlobsWithAdresses(key, item);
        };

        public func delete(key : Blob, item : CommonMemoryHashKeyList.MemoryStorage, address : Nat64):Result.Result<Blob,Text> {
            CommonMemoryHashKeyList.multiBlob_delete(key, item, address);
        };

        public func delete_all(key : Blob, item : CommonMemoryHashKeyList.MemoryStorage) {
            CommonMemoryHashKeyList.multiBlob_delete_all(key, item);
        };

    };


Example:</br>

    import lib "mo:Memory-HashList";
    import Blob "mo:base/Blob";
    import Text "mo:base/Text";

    actor {
    public query func multiBlob_usage_example() : async () {

        // (1) Create and get new memory_storage (should be used as stable var in production)

        let memoryStore = lib.get_new_memory_storage();
        let mem = lib.MemoryMultiHashList;


        // (2) Create key and value that should be stored

        let key1 : Blob = lib.Blobify.Text.to_blob("key1");
        let blob1 : Blob = lib.Blobify.Text.to_blob("hello");
        let blob2 : Blob = lib.Blobify.Text.to_blob("hello");
        let blob3 : Blob = lib.Blobify.Text.to_blob("hello");


        // (3) Store the blobs into memory for the key 'key1'

        ignore mem.append(key1, memoryStore, blob1);
        ignore mem.append(key1, memoryStore, blob2);
        ignore mem.append(key1, memoryStore, blob3);


        // (4) Get all the stored values for the key 'key1'

        let allValues : [Blob] = mem.get_all(key1, memoryStore);


        // (5) Get the second stored value:

        let secondValue : ?Blob = mem.get_by_index(key1, memoryStore, 1);


        // (6) Get the last two stored values:

        let lastTwoValues : [Blob] = mem.get_by_index_and_count(key1, memoryStore, 1, 2);


        // (7) Get the used memory-addresses:

        let usedMemoryAddresses : [Nat64] = mem.get_all_memory_addresses(key1, memoryStore);


        // (8) Get item by provided memory-address:

        let firstItem : ?Blob = mem.get_by_memory_address(key1, memoryStore, usedMemoryAddresses[0]);


        // (9) Remove the first value:

        ignore mem.delete(key1, memoryStore, usedMemoryAddresses[0]);
    };
    };

