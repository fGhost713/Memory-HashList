// @testmode wasi
import Lib "../src/lib";
import Blob "mo:base/Blob";
import Text "mo:base/Text";
import Option "mo:base/Option";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";
import Nat64 "mo:base/Nat64";
import List "mo:base/List";
import Array "mo:base/Array";
import Nat32 "mo:base/Nat32";
import Random "mo:base/Random";
import Nat "mo:base/Nat";
import Nat8 "mo:base/Nat8";
import LibKey "../src/modules/libKey";
import GlobalFunctions "../src/helpers/globalFunctions";
import StableTrieMap "mo:StableTrieMap";
import Vector "mo:vector";
import { test; suite } "mo:test";
import Leaf "mo:augmented-btrees/BpTree/Leaf";
import LibMemoryHashList "../src/modules/libMemoryHashList";
import Fuzz "mo:fuzz";

let globalBlobHashFunction = GlobalFunctions.blobHash;
let dummyBlob : Blob = Lib.Blobify.Text.to_blob("dummyBlob");
let dummyNat32 : Nat32 = 732354;

 type OwnType = {
        myNumber : Nat;
        myText : Text;
    };
    let ownType1 : OwnType = {
        myNumber : Nat = 2345;
        myText : Text = "Hello World";
    };
    let ownType2 : OwnType = {
        myNumber : Nat = 79;
        myText : Text = "";
    };
    let ownType3 : OwnType = {
        myNumber : Nat = 0;
        myText : Text = "My test text";
    };

    let ownType1Blob : Blob = to_candid (ownType1);
    let ownType2Blob : Blob = to_candid (ownType2);
    let ownType3Blob : Blob = to_candid (ownType3);

    func ownType_getDefaultType() : OwnType {
        let result : OwnType = {
            myNumber = 0;
            myText = "";
        };
    };

suite(
    "LibMemoryHashList Tests",
    func() {
        test(
            "'add' tests",
            func() {

                let mem = Lib.get_new_memory_storage(8);
                let hashList = LibMemoryHashList.libMemoryHashList(mem);

                 
                let key1 : Blob = Lib.Blobify.Text.to_blob("key1");
                let key2 : Blob = Lib.Blobify.Text.to_blob("key2");
                let key3 : Blob = Lib.Blobify.Text.to_blob("key3");

                assert hashList.get_last_index(key1) == null;

                assert hashList.add(key1, ownType1Blob) == ?0;
                assert hashList.add(key1, ownType1Blob) == ?1;
                assert hashList.add(key1, ownType2Blob) == ?2;
                assert hashList.add(key1, ownType3Blob) == ?3;

                assert hashList.add(key2, ownType2Blob) == ?0;
                assert hashList.add(key2, ownType3Blob) == ?1;
                assert hashList.add(key2, ownType1Blob) == ?2;

                assert hashList.get_last_index(key1) == ?3;

                assert hashList.get_at_index(key1,0) == ?ownType1Blob;
                assert hashList.get_at_index(key1,1) == ?ownType1Blob;
                assert hashList.get_at_index(key1,2) == ?ownType2Blob;
                assert hashList.get_at_index(key1,3) == ?ownType3Blob;
                assert hashList.get_at_index(key1,4) == null;

                assert hashList.get_at_index(key2,0) == ?ownType2Blob;
                assert hashList.get_at_index(key2,1) == ?ownType3Blob;
                assert hashList.get_at_index(key2,2) == ?ownType1Blob;
                assert hashList.get_at_index(key2,3) == null;

                assert hashList.get_at_index(key3,0) == null;

                assert hashList.get_last_index(key1) == ?3;
                assert hashList.get_last_index(key2) == ?2;
                assert hashList.get_last_index(key3) == null;


            },

        );
        test(
            "'get_at_range' Tests",
            func() {

                let mem = Lib.get_new_memory_storage(8);
                let hashList = LibMemoryHashList.libMemoryHashList(mem);

                 
                let key1 : Blob = Lib.Blobify.Text.to_blob("key1");
                let key2 : Blob = Lib.Blobify.Text.to_blob("key2");
                let key3 : Blob = Lib.Blobify.Text.to_blob("key3");

                assert hashList.get_last_index(key1) == null;

                ignore hashList.add(key1, ownType1Blob);
                ignore hashList.add(key1, ownType1Blob);
                ignore hashList.add(key1, ownType2Blob);
                ignore hashList.add(key1, ownType3Blob);

                ignore hashList.add(key2, ownType2Blob);
                ignore hashList.add(key2, ownType3Blob);
                ignore hashList.add(key2, ownType1Blob);

                assert hashList.get_last_index(key1) == ?3;
                assert hashList.get_at_range(key1, 5,2) == [];    

                assert hashList.get_at_range(key1, 2,5) == [ownType2Blob,ownType3Blob ]; 
                assert hashList.get_at_range(key1, 1,3) == [ownType1Blob, ownType2Blob,ownType3Blob ];   
              
            },

        );

        test(
            "'get_all_keys' Tests",
            func() {

                let mem = Lib.get_new_memory_storage(8);
                let hashList = LibMemoryHashList.libMemoryHashList(mem);

                 
                let key1 : Blob = Lib.Blobify.Text.to_blob("key1");
                let key2 : Blob = Lib.Blobify.Text.to_blob("key2");
                let key3 : Blob = Lib.Blobify.Text.to_blob("key3");
                assert hashList.get_all_keys() == [];

                ignore hashList.add(key1, ownType1Blob);
                ignore hashList.add(key1, ownType1Blob);
                ignore hashList.add(key1, ownType2Blob);
                ignore hashList.add(key1, ownType3Blob);

                ignore hashList.add(key2, ownType2Blob);
                ignore hashList.add(key2, ownType3Blob);
                ignore hashList.add(key2, ownType1Blob);

                ignore hashList.add(key3, ownType3Blob);

                assert hashList.get_all_keys() == [key3, key2, key1];

                ignore hashList.remove_value_at_index(key2,2);
                ignore hashList.remove_value_at_index(key2,1);

                assert hashList.get_all_keys() == [key3, key2, key1];

                ignore hashList.remove_value_at_index(key2,0);
                assert hashList.remove_value_at_index(key2,0) == #err("Existing value not found for this key at index: 0");
                 
                assert hashList.get_all_keys() == [key3, key1];
              
            },

        );

        test(
            "'update_value_at_index' Tests",
            func() {

                let mem = Lib.get_new_memory_storage(8);
                let hashList = LibMemoryHashList.libMemoryHashList(mem);

                let key1 : Blob = Lib.Blobify.Text.to_blob("key1");
 
                assert hashList.get_all_keys() == [];

                ignore hashList.add(key1, ownType1Blob);
                ignore hashList.add(key1, ownType1Blob);
                ignore hashList.add(key1, ownType2Blob);
                ignore hashList.add(key1, ownType3Blob);

                ignore hashList.update_value_at_index(key1, 1, ownType3Blob);
                assert hashList.get_at_index(key1, 1) == ?ownType3Blob;

                assert hashList.get_at_range(key1, 0, 7) 
                        == [ownType1Blob,ownType3Blob, ownType2Blob, ownType3Blob];

                assert hashList.update_value_at_index(key1, 12, ownType3Blob) 
                        == #err("Existing value not found for this key at index 12");

                ignore hashList.update_value_at_index(key1, 0, ownType3Blob);
                assert hashList.get_at_index(key1, 0) == ?ownType3Blob;        

            },

        );

         test(
            "'remove_value_at_index' Tests",
            func() {

                let mem = Lib.get_new_memory_storage(8);
                let hashList = LibMemoryHashList.libMemoryHashList(mem);

                let key1 : Blob = Lib.Blobify.Text.to_blob("key1");
  
                assert hashList.get_all_keys() == [];

                ignore hashList.add(key1, ownType1Blob);
                ignore hashList.add(key1, ownType1Blob);
                ignore hashList.add(key1, ownType2Blob);
                ignore hashList.add(key1, ownType3Blob);

                let result = hashList.remove_value_at_index(key1, 1);
                assert hashList.get_at_index(key1, 1) == ?ownType2Blob;

                ignore hashList.remove_value_at_index(key1, 0);
                assert hashList.get_at_index(key1, 0) == ?ownType2Blob;
                assert hashList.get_at_index(key1, 1) == ?ownType3Blob;
                      
                assert hashList.remove_value_at_index(key1, 12) 
                         == #err("Existing value not found for this key at index: 12");
            },

        );

        test(
            "'get_last_index' Tests",
            func() {

                let mem = Lib.get_new_memory_storage(8);
                let hashList = LibMemoryHashList.libMemoryHashList(mem);

                let key1 : Blob = Lib.Blobify.Text.to_blob("key1");
  
                assert hashList.get_last_index(key1) == null;

                ignore hashList.add(key1, ownType1Blob);
                assert hashList.get_last_index(key1) ==  ?0;

                ignore hashList.add(key1, ownType1Blob);
                assert hashList.get_last_index(key1) ==  ?1;

                ignore hashList.add(key1, ownType2Blob);
                assert hashList.get_last_index(key1) ==  ?2;

                ignore hashList.add(key1, ownType3Blob);
                assert hashList.get_last_index(key1) ==  ?3;

                let result = hashList.remove_value_at_index(key1, 1);
                assert hashList.get_last_index(key1) ==  ?2;
            },

        );

         test(
            "Doing many different operations Tests",
            func() {

                let seed = 123456789;
                var fuzz = Fuzz.fromSeed(seed);
                // let randomNumber = fuzz.nat.randomRange(23223, 5133231233232343242312352342);
                // Debug.print("random");
                // Debug.print(debug_show(randomNumber));

                let mem = Lib.get_new_memory_storage(8);
                let hashList = LibMemoryHashList.libMemoryHashList(mem);

                let key1 : Blob = Lib.Blobify.Text.to_blob("key1");
  
                let refResult:Vector.Vector<Blob> = Vector.new();
                let possibleValues:Vector.Vector<Blob> = Vector.new();

                // create 255 OwnType-types as blobs with random field values
                for(index in Iter.range(0,255)){

                    let dynamicType : OwnType = {
                            myNumber : Nat = fuzz.nat.randomRange(0, 125554);
                            myText : Text = fuzz.text.randomAlphabetic(fuzz.nat.randomRange(0, 300));
                    };
                };

                assert true == true;

                for(index in Iter.range(0,100)){
                    let randomOperation: Nat = fuzz.nat.randomRange(0, 2);
                    Debug.print(debug_show(randomOperation));
                    switch(randomOperation){
                        case (0){
                             // get_at_index

                             let randomIndex =fuzz.nat.randomRange(0, 5);
                             let actualResult:?Blob = hashList.get_at_index(key1, randomIndex);
                             let expectedResult = 
                             switch(actualResult){
                                case (?blob){

                                };
                                case (_){

                                };
                             }

                        };
                        case (_){
                            // do nothing
                        };

                    }


                };



                // assert hashList.get_last_index(key1) == null;

                // ignore hashList.add(key1, ownType1Blob);
                // assert hashList.get_last_index(key1) ==  ?0;

                // ignore hashList.add(key1, ownType1Blob);
                // assert hashList.get_last_index(key1) ==  ?1;

                // ignore hashList.add(key1, ownType2Blob);
                // assert hashList.get_last_index(key1) ==  ?2;

                // ignore hashList.add(key1, ownType3Blob);
                // assert hashList.get_last_index(key1) ==  ?3;

                // let result = hashList.remove_value_at_index(key1, 1);
                // assert hashList.get_last_index(key1) ==  ?2;
            },

        );
        
    },
);
