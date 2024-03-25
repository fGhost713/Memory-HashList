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

        bench.name("Adding new items");
        bench.description("Add new items benchmark");

       
        bench.cols(["1", "10", "100", "1000", "10000"]);
        
        type OwnType = {
            myNumber : Nat;
            myText : Text;
        };

        type SecondOwnType = {
            myNumber : Nat;
            myText : Text;
            myText2 : Text;
            myText3 : Text;
            myText4 : Text;
            myText5 : Text;
        };

        let ownType1 : OwnType = {
            myNumber : Nat = 2345;
            myText : Text = "Hello World";
        };

        let ownType2 : SecondOwnType = {
            myNumber : Nat = 2345;
            myText : Text = "Hello World53453455534534555345345553453455534534555345345553453455";
            myText2 : Text = "5345345345553453455534534555345345553453455534534555345345553453455";
            myText3 : Text = "897898745645653453455534534555345345553453455534534555345345553453455";
            myText4 : Text = "8903242115868223453453455534534555345345553453455534534555345345521";
            myText5 : Text = "867678223477943534545653453455534534555345345553453455534534555345345553453455";
        };

       

        let ownType1Blob : Blob = to_candid (ownType1);
        let ownType2Blob : Blob = to_candid (ownType2);

        let row1Text:Text = "Adding new items (each blob-size " # debug_show(ownType1Blob.size())#" bytes)";
        let row2Text:Text = "Adding new items (each blob-size " # debug_show(ownType2Blob.size())#" bytes)";

        bench.rows([row1Text, row2Text]);

        let mem = Lib.get_new_memory_storage(0);
        let hashList = LibMemoryHashList.libMemoryHashList(mem);

        let keysVec:Vector.Vector<Blob> = Vector.new();
        for(i in Iter.range(1,10)){
            Vector.add<Blob>(keysVec, Lib.Blobify.Text.to_blob("key"#debug_show(i)));
        };
        let keys = Vector.toArray(keysVec);
          
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

                if (row == row2Text){
                    columnIndex:= columnIndex + 5;
                };
                let key = keys[columnIndex];

                for (i in Iter.range(1, n)) {
                    ignore hashList.add(key, ownType1Blob);   
                };
            }
        );

        bench;
    };
};
