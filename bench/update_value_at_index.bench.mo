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

module {
    public func init() : Bench.Bench {

        let bench = Bench.Bench();

        bench.name("Update value at index");
        bench.description("Update value at index benchmark");

        bench.rows(["Update value at index"]);
        bench.cols(["1", "10", "100", "1000", "10000"]);
        
        type OwnType = {
            myNumber : Nat;
            myText : Text;
        };

        let ownType1 : OwnType = {
            myNumber : Nat = 2345;
            myText : Text = "Hello World";
        };


        let ownType1Blob : Blob = to_candid (ownType1);
    
        let mem = Lib.get_new_memory_storage(0);
        let hashList = LibMemoryHashList.libMemoryHashList(mem);
        let key1 : Blob = Lib.Blobify.Text.to_blob("key1"); 

        let buffer = Buffer.Buffer<Blob>(10002);
        for (i in Iter.range(1, 10001)) {            
            ignore hashList.add(key1, ownType1Blob);     
        };       

        bench.runner(
            func(row, col) {
                let ?n = Nat.fromText(col);
                
                for (i in Iter.range(1, n)) {
                    ignore hashList.update_at_index(key1, i,ownType1Blob); 
                };
                
            }
        );

        bench;
    };
};
