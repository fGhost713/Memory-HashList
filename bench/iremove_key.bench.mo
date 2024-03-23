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

        bench.name("Remove key");
        bench.description("Remove key benchmark.");

        bench.rows(["Remove key"]);
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
            myText : Text = "Hero World";
        };

        let ownType1Blob : Blob = to_candid (ownType1);
        let ownTypeMuchBiggerBlob : Blob = to_candid (ownTypeMuchBigger);

        let hashList = LibMemoryHashList.libMemoryHashList(Lib.get_new_memory_storage(0));

        let key1 : Blob = Lib.Blobify.Text.to_blob("key1");
        let key2 : Blob = Lib.Blobify.Text.to_blob("key2");
        let key3 : Blob = Lib.Blobify.Text.to_blob("key3");
        let key4 : Blob = Lib.Blobify.Text.to_blob("key4");
        let key5 : Blob = Lib.Blobify.Text.to_blob("key5");

        for (i in Iter.range(1, 1)) {
            ignore hashList.add(key1, ownType1Blob);
        };

        for (i in Iter.range(1, 10)) {
            ignore hashList.add(key2, ownType1Blob);
        };

        for (i in Iter.range(1, 100)) {
            ignore hashList.add(key3, ownType1Blob);

        };
        for (i in Iter.range(1, 1000)) {
            ignore hashList.add(key4, ownType1Blob);

        };

        for (i in Iter.range(1, 10000)) {
            ignore hashList.add(key5, ownType1Blob);

        };

        bench.runner(
            func(row, col) {
                let n = Option.get(Nat.fromText(col), 1);

                let key : Blob = switch (n) {
                    case (1) { key1 };
                    case (10) { key2 };
                    case (100) { key3 };
                    case (1000) { key4 };
                    case (10000) { key5 };
                    case (_) {
                        Debug.trap("Should not occur.");
                    };
                };

                for (i in Iter.range(1, n)) {

                    hashList.remove_key(key);
                };

            }
        );

        bench;
    };
};
