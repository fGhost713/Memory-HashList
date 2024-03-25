import Bench "mo:bench";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";
import lib "../src/lib";
import Blob "mo:base/Blob";
import Text "mo:base/Text";
import Option "mo:base/Option";
import Debug "mo:base/Debug";
import List "mo:base/List";
import Buffer "mo:base/Buffer";
import LibMemoryHashList "../src/modules/libMemoryHashList";
import Lib "../src/lib";
import Vector "mo:vector";

module {
    public func init() : Bench.Bench {

        let bench = Bench.Bench();

        bench.name("Update value at index with fallback to put");
        bench.description("Update value at index with fallback to put benchmark.");

        bench.rows(["Update value at index with fallback to put"]);
        bench.cols(["1", "10", "100", "1000", "10000"]);
        
        type OwnType = {
            myNumber : Nat;
            myText : Text;
        };

        let ownType1 : OwnType = {
            myNumber : Nat = 2345;
            myText : Text = "Hello World";
        };

        let ownTypeMuchBigger : OwnType = {
            myNumber : Nat = 245324234324;
            myText : Text = "Hero World - Hero World  -Hero World  -Hero World  -Hero World";
        };


        let ownType1Blob : Blob = to_candid (ownType1);
        let ownTypeMuchBiggerBlob : Blob = to_candid (ownTypeMuchBigger);

        let mem = Lib.get_new_memory_storage(0);
        let hashList = LibMemoryHashList.libMemoryHashList(mem);

        let keysVec:Vector.Vector<Blob> = Vector.new();
        for(i in Iter.range(1,10)){
            Vector.add<Blob>(keysVec, Lib.Blobify.Text.to_blob("key"#debug_show(i)));
        };
        let keys = Vector.toArray(keysVec);


        let buffer = Buffer.Buffer<Blob>(10002);
        for (i in Iter.range(1, 1)) {            
            ignore hashList.add(keys[0], ownType1Blob);     
        }; 
         for (i in Iter.range(1, 11)) {            
            ignore hashList.add(keys[1], ownType1Blob);     
        };       
         for (i in Iter.range(1, 101)) {            
            ignore hashList.add(keys[2], ownType1Blob);     
        };       
        
        for (i in Iter.range(1, 1001)) {            
            ignore hashList.add(keys[3], ownType1Blob);     
        };       
        
        for (i in Iter.range(1, 10001)) {            
            ignore hashList.add(keys[4], ownType1Blob);     
        };                

        bench.runner(
            func(row, col) {
                let n = Option.get(Nat.fromText(col),0);
                

                var columnIndex = switch(n){
                    case (1){0;};
                    case (10){1;};
                    case (100){2;};
                    case (1000){3;};
                    case (10000){4;};                    
                    case (_){
                        Debug.trap("Error!");
                    };
                };
                
                let key = keys[columnIndex];
                
                for (i in Iter.range(1, n)) {
                    ignore hashList.update_at_index(key, i,ownTypeMuchBiggerBlob); 
                };
                
            }
        );

        bench;
    };
};
