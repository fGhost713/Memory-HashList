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

        bench.name("Insert at index");
        bench.description("Insert at index -  benchmark. (slow)");

        bench.rows(["Insert value at first index","Insert value at middle index","Insert value at end index"]);
        bench.cols(["1", "10", "100", "1000", "2000"]); //, "10000"]);

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
            myText : Text = "Hero World";
        };

        let ownType1Blob : Blob = to_candid (ownType1);
        let ownTypeMuchBiggerBlob : Blob = to_candid (ownTypeMuchBigger);

        
        let hashList = LibMemoryHashList.libMemoryHashList(Lib.get_new_memory_storage(0));
       
        let key1_1 : Blob = Lib.Blobify.Text.to_blob("key1_1");
        let key1_2 : Blob = Lib.Blobify.Text.to_blob("key1_2");
        let key1_3 : Blob = Lib.Blobify.Text.to_blob("key1_3");
 

        let key2_1 : Blob = Lib.Blobify.Text.to_blob("key2_1");
        let key2_2 : Blob = Lib.Blobify.Text.to_blob("key2_2");
        let key2_3 : Blob = Lib.Blobify.Text.to_blob("key2_3");
   

        let key3_1 : Blob = Lib.Blobify.Text.to_blob("key3_1");
        let key3_2 : Blob = Lib.Blobify.Text.to_blob("key3_2");
        let key3_3 : Blob = Lib.Blobify.Text.to_blob("key3_3");
    

        let key4_1 : Blob = Lib.Blobify.Text.to_blob("key4_1");
        let key4_2 : Blob = Lib.Blobify.Text.to_blob("key4_2");
        let key4_3 : Blob = Lib.Blobify.Text.to_blob("key4_3");
 

        let key5_1 : Blob = Lib.Blobify.Text.to_blob("key5_1");
        let key5_2 : Blob = Lib.Blobify.Text.to_blob("key5_2");
        let key5_3 : Blob = Lib.Blobify.Text.to_blob("key5_3");
   
 
        for (i in Iter.range(1, 1)) {
            ignore hashList.add(key1_1, ownType1Blob);
            ignore hashList.add(key1_2, ownType1Blob);
            ignore hashList.add(key1_3, ownType1Blob);
  
        };
        for (i in Iter.range(1, 10)) {
            ignore hashList.add(key2_1, ownType1Blob);
            ignore hashList.add(key2_2, ownType1Blob);
            ignore hashList.add(key2_3, ownType1Blob);
  
        };
        for (i in Iter.range(1, 100)) {
            ignore hashList.add(key3_1, ownType1Blob);
            ignore hashList.add(key3_2, ownType1Blob);
            ignore hashList.add(key3_3, ownType1Blob);
  
        };
        for (i in Iter.range(1, 1000)) {
            ignore hashList.add(key4_1, ownType1Blob);
            ignore hashList.add(key4_2, ownType1Blob);
            ignore hashList.add(key4_3, ownType1Blob);
       
        };

        for (i in Iter.range(1, 2000)) {
            ignore hashList.add(key5_1, ownType1Blob);
            ignore hashList.add(key5_2, ownType1Blob);
            ignore hashList.add(key5_3, ownType1Blob);
     
        };

    
        bench.runner(
            func(row, col) {
                let n = Option.get(Nat.fromText(col), 1);

                var rowNumberText:Text ="";
                

                switch (row) {
                    case ("Insert value at first index") {
                        rowNumberText := "1";
                    };
                    case ("Insert value at middle index") {
                            rowNumberText := "2";
                    };
                    case ("Insert value at end index") {
                        rowNumberText := "3";
                    };
                    case (_) {
                        // do nothing
                    };
                };

                let what:Blob = Lib.Blobify.Text.to_blob("key1_");

                let key:Blob = switch (n) {
                    case (1) { Lib.Blobify.Text.to_blob("key1_"#rowNumberText); };
                    case (10) { Lib.Blobify.Text.to_blob("key2_"#rowNumberText); };
                    case (100) { Lib.Blobify.Text.to_blob("key3_"#rowNumberText); };
                    case (1000) {Lib.Blobify.Text.to_blob("key4_"#rowNumberText); };
                    case (2000) { Lib.Blobify.Text.to_blob("key5_"#rowNumberText); };
                    case (_) {
                        Debug.trap("Should not occur.");
                    };
                };


                switch (row) {
                    case ("Insert value at first index") {
                        for (i in Iter.range(1, n)) {

                            ignore hashList.insert_at_index(key, 0, ownType1Blob);
                        };
                    };
                    case ("Insert value at middle index") {
                        for (i in Iter.range(1, n)) {

                            let index : Nat = (n + i) / 2;
                            ignore hashList.insert_at_index(key, index, ownType1Blob);
                        };
                    };
                    case ("Insert value at end index") {

                        var index : Nat = n -1;
                        for (i in Iter.range(1, n)) {

                            index := index +1;
                            ignore hashList.insert_at_index(key, index, ownType1Blob);
                        };
                    };
                    case (_) {
                        // do nothing
                    };

                };

            }
        );

        bench;
    };
};
