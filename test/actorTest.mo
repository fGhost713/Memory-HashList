// @testmode replica
import Debug "mo:base/Debug";
import lib "../src/lib";
import Blob "mo:base/Blob";
import Text "mo:base/Text";
import Iter "mo:base/Iter";
import Option "mo:base/Option";
import Vector "mo:vector";
import MemoryRegion "mo:memory-region/MemoryRegion";
import Prim "mo:⛔";

// @testmode replica
persistent actor {

    Debug.print("hello world");
    stable var mem = lib.get_new_memory_storage(8);
    transient let hashList = lib.MemoryHashList(mem);



    public shared query func vector_test():async (){

        let vec:Vector.Vector<Nat> = Vector.new();

        Vector.add(vec,1);
        for(i in Iter.range(2,10000)){
            let lastItem:Nat = Vector.last<Nat>(vec);
            //let removedItem:?Nat = Vector.removeLast(vec);
            //let val:Nat = i-1;
            Debug.print("index: "#debug_show(i) #" last item: " #debug_show(lastItem));
            assert lastItem == Option.make(i-1);
            //Vector.add(vec,i-1);
            Vector.add(vec,i);

        };
        // Vector.add(vec,1);
        // Vector.add(vec,2);

        // Vector.ins
        // let removedItem:?Nat = Vector.removeLast(vec);
        // Debug.print("Removed item: "#debug_show(removedItem));

        // Debug.print("Vector at index 0: " # debug_show(Vector.get(vec,0)));
        // Debug.print("Vector at index 0: " # debug_show(Vector.get(vec,1)));


    };


    public shared query func show() : async [?Text] {

        let key = lib.Blobify.Text.to_blob("key1");

        let result : Vector.Vector<?Text> = Vector.new();

        for (i in Iter.range(0, 5)) {
            let valueOrNull : ?Blob = hashList.get_at_index(key, i);
            switch (valueOrNull) {
                case (?value) {
                    let text : Text = lib.Blobify.Text.from_blob(value);
                    Vector.add<?Text>(result, ?text);
                };
                case (_) {
                    Vector.add<?Text>(result, null);
                };
            };
        };

        return Vector.toArray(result);

    };

    public shared query func show_items_count():async Nat{
        let key = lib.Blobify.Text.to_blob("key1");
        Option.unwrap(hashList.get_last_index(key));
    };

    public shared query func show_items_count2():async Nat{
        let key = lib.Blobify.Text.to_blob("key2");
        Option.unwrap(hashList.get_last_index(key));
    };

    public shared query func show_mem_calc():async MemoryRegion.MemoryInfo{

        //let allAlocSizeInBytes = MemoryRegion.size(mem.memory_region);
        //return allAlocSizeInBytes;
        MemoryRegion.memoryInfo(mem.memory_region);
    };

    public shared query func show_mem():async (Nat,Nat,Nat,Nat){
        let memSize =  Prim.rts_memory_size();
        let maxLiveSize = Prim.rts_max_live_size();
        let totalAllocation = Prim.rts_total_allocation();
        let reclamed = Prim.rts_reclaimed();
        (memSize, maxLiveSize, totalAllocation, reclamed);
    };

    public shared query func show_heap():async Nat{
        Prim.rts_heap_size();
    };


    public shared func add5(val : Text) : async () {
        let blob : Blob = lib.Blobify.Text.to_blob(val);
        let key = lib.Blobify.Text.to_blob("key1");
        ignore hashList.add(key, blob);
    };

    public shared func add6(val : Text) : async () {
        let blob : Blob = lib.Blobify.Text.to_blob(val);
        let key = lib.Blobify.Text.to_blob("key1");
        ignore lib.StableMemoryHashList.add(mem, key, blob);
    };

    public shared func add_many():async (){

        let blob : Blob = lib.Blobify.Text.to_blob("manyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyVals");
        let key = lib.Blobify.Text.to_blob("key1");
        for(index in Iter.range(0,10000)){
            ignore hashList.add(key, blob);
        };

    };

    public shared func add_many2():async (){

        let blob : Blob = lib.Blobify.Text.to_blob("maanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValanyValnyVals");
        let key = lib.Blobify.Text.to_blob("key2");
        for(index in Iter.range(0,10000)){
            ignore hashList.add(key, blob);
        };

    };

};
