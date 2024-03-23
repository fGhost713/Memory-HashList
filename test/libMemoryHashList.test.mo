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
import VectorHelper "Helper/vectorHelper";

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

                assert hashList.add(key1, ownType1Blob).0 == 0;
                assert hashList.add(key1, ownType1Blob).0 == 1;
                assert hashList.add(key1, ownType2Blob).0 == 2;
                assert hashList.add(key1, ownType3Blob).0 == 3;

                assert hashList.add(key2, ownType2Blob).0 == 0;
                assert hashList.add(key2, ownType3Blob).0 == 1;
                assert hashList.add(key2, ownType1Blob).0 == 2;

                assert hashList.get_last_index(key1) == ?3;

                assert hashList.get_at_index(key1, 0) == ?ownType1Blob;
                assert hashList.get_at_index(key1, 1) == ?ownType1Blob;
                assert hashList.get_at_index(key1, 2) == ?ownType2Blob;
                assert hashList.get_at_index(key1, 3) == ?ownType3Blob;
                assert hashList.get_at_index(key1, 4) == null;

                assert hashList.get_at_index(key2, 0) == ?ownType2Blob;
                assert hashList.get_at_index(key2, 1) == ?ownType3Blob;
                assert hashList.get_at_index(key2, 2) == ?ownType1Blob;
                assert hashList.get_at_index(key2, 3) == null;

                assert hashList.get_at_index(key3, 0) == null;

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
                assert hashList.get_at_range(key1, 5, 2) == [];

                assert hashList.get_at_range(key1, 2, 5) == [ownType2Blob, ownType3Blob];
                assert hashList.get_at_range(key1, 1, 3) == [ownType1Blob, ownType2Blob, ownType3Blob];

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

                ignore hashList.remove_at_index(key2, 2);
                ignore hashList.remove_at_index(key2, 1);

                assert hashList.get_all_keys() == [key3, key2, key1];

                ignore hashList.remove_at_index(key2, 0);
                assert hashList.remove_at_index(key2, 0) == #err("Existing value not found for this key at index: 0");

                assert hashList.get_all_keys() == [key3, key1];

            },

        );

        test(
            "'update_at_index' Tests",
            func() {

                let mem = Lib.get_new_memory_storage(8);
                let hashList = LibMemoryHashList.libMemoryHashList(mem);

                let key1 : Blob = Lib.Blobify.Text.to_blob("key1");

                assert hashList.get_all_keys() == [];

                ignore hashList.add(key1, ownType1Blob);
                ignore hashList.add(key1, ownType1Blob);
                ignore hashList.add(key1, ownType2Blob);
                ignore hashList.add(key1, ownType3Blob);

                ignore hashList.update_at_index(key1, 1, ownType3Blob);
                assert hashList.get_at_index(key1, 1) == ?ownType3Blob;

                assert hashList.get_at_range(key1, 0, 7) == [ownType1Blob, ownType3Blob, ownType2Blob, ownType3Blob];

                assert hashList.update_at_index(key1, 12, ownType3Blob) == #err("Existing value not found for this key at index 12");

                ignore hashList.update_at_index(key1, 0, ownType3Blob);
                assert hashList.get_at_index(key1, 0) == ?ownType3Blob;

            },

        );

        test(
            "'remove_at_index' Tests",
            func() {

                let mem = Lib.get_new_memory_storage(8);
                let hashList = LibMemoryHashList.libMemoryHashList(mem);

                let key1 : Blob = Lib.Blobify.Text.to_blob("key1");

                assert hashList.get_all_keys() == [];

                ignore hashList.add(key1, ownType1Blob);
                ignore hashList.add(key1, ownType1Blob);
                ignore hashList.add(key1, ownType2Blob);
                ignore hashList.add(key1, ownType3Blob);

                let result = hashList.remove_at_index(key1, 1);
                assert hashList.get_at_index(key1, 1) == ?ownType2Blob;

                ignore hashList.remove_at_index(key1, 0);
                assert hashList.get_at_index(key1, 0) == ?ownType2Blob;
                assert hashList.get_at_index(key1, 1) == ?ownType3Blob;
             
                assert hashList.remove_at_index(key1, 12) == #err("Existing value not found for this key at index: 12");
            },

        );

         test(
            "'remove_at_range' Tests",
            func() {
 
                let mem = Lib.get_new_memory_storage(8);
                let hashList = LibMemoryHashList.libMemoryHashList(mem);

                let key1 : Blob = Lib.Blobify.Text.to_blob("key1");

                assert hashList.get_all_keys() == [];

                ignore hashList.add(key1, ownType1Blob);
                ignore hashList.add(key1, ownType1Blob);
                ignore hashList.add(key1, ownType2Blob);
                ignore hashList.add(key1, ownType3Blob);
                ignore hashList.add(key1, ownType2Blob);
                ignore hashList.add(key1, ownType3Blob);

                ignore hashList.remove_at_range(key1, 1, ?3);
                assert hashList.get_at_index(key1, 1) == ?ownType2Blob;

        
                assert hashList.get_at_index(key1, 0) == ?ownType1Blob;
                assert hashList.get_at_index(key1, 1) == ?ownType2Blob;
                assert hashList.get_at_index(key1, 2) == ?ownType3Blob;
                assert hashList.get_at_index(key1, 3) == null;
             

                assert hashList.remove_at_range(key1, 12, ?22) == #err("Existing value not found for this key at index: 12");
            
                ignore hashList.add(key1, ownType1Blob);
                ignore hashList.add(key1, ownType1Blob);
                ignore hashList.add(key1, ownType2Blob);
                ignore hashList.add(key1, ownType3Blob);
                ignore hashList.add(key1, ownType2Blob);
                ignore hashList.add(key1, ownType2Blob);
                ignore hashList.add(key1, ownType3Blob);
                ignore hashList.add(key1, ownType2Blob);
                ignore hashList.add(key1, ownType3Blob);
                ignore hashList.add(key1, ownType2Blob);
                ignore hashList.add(key1, ownType3Blob);
                ignore hashList.remove_at_range(key1, 6, null);

                ignore hashList.remove_at_range(key1, 12, ?1);

                ignore hashList.remove_at_range(key1, 4, ?2);

            
            },

        );

        test(
            "'insert_at_index' Tests",
            func() {

                let mem = Lib.get_new_memory_storage(8);
                let hashList = LibMemoryHashList.libMemoryHashList(mem);

                let key1 : Blob = Lib.Blobify.Text.to_blob("key1");

                assert hashList.get_all_keys() == [];

                ignore hashList.add(key1, ownType1Blob);
                ignore hashList.add(key1, ownType1Blob);
                ignore hashList.add(key1, ownType2Blob);
                ignore hashList.add(key1, ownType3Blob);

                let result = hashList.insert_at_index(key1, 1, ownType3Blob);
                
                assert hashList.get_at_index(key1, 1) == ?ownType3Blob;

                ignore hashList.insert_at_index(key1, 0, ownType2Blob);
                assert hashList.get_at_index(key1, 0) == ?ownType2Blob;
                assert hashList.get_at_index(key1, 1) == ?ownType1Blob;
                assert hashList.get_at_index(key1, 2) == ?ownType3Blob;

                assert hashList.insert_at_index(key1, 12, ownType1Blob) == #err("Index not found.");
            },

        );

         test(
            "'insert_many_at_index' Tests",
            func() {


                let mem = Lib.get_new_memory_storage(8);
                let hashList = LibMemoryHashList.libMemoryHashList(mem);

                let key1 : Blob = Lib.Blobify.Text.to_blob("key1");

                assert hashList.get_all_keys() == [];

                ignore hashList.add(key1, ownType1Blob);
                ignore hashList.add(key1, ownType1Blob);
                ignore hashList.add(key1, ownType1Blob);
              

                let manyItems:[Blob] = [ownType3Blob];
                ignore hashList.insert_many_at_index(key1, 1, manyItems);
                assert hashList.get_at_index(key1, 1) == ?ownType3Blob;

                hashList.remove_key(key1);
                ignore hashList.add(key1, ownType1Blob);
                ignore hashList.add(key1, ownType1Blob);
                ignore hashList.add(key1, ownType1Blob);

                let manyItems2:[Blob] = [ownType3Blob,ownType2Blob,ownType3Blob];
                ignore hashList.insert_many_at_index(key1, 1, manyItems2);

                assert hashList.get_at_index(key1, 0) == ?ownType1Blob;
                assert hashList.get_at_index(key1, 1) == ?ownType3Blob;
                assert hashList.get_at_index(key1, 2) == ?ownType2Blob;
                assert hashList.get_at_index(key1, 3) == ?ownType3Blob;
                assert hashList.get_at_index(key1, 4) == ?ownType1Blob;
                assert hashList.get_at_index(key1, 5) == ?ownType1Blob;
                assert hashList.get_at_index(key1, 6) == null;

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
                assert hashList.get_last_index(key1) == ?0;

                ignore hashList.add(key1, ownType1Blob);
                assert hashList.get_last_index(key1) == ?1;

                ignore hashList.add(key1, ownType2Blob);
                assert hashList.get_last_index(key1) == ?2;

                ignore hashList.add(key1, ownType3Blob);
                assert hashList.get_last_index(key1) == ?3;

                let result = hashList.remove_at_index(key1, 1);
                assert hashList.get_last_index(key1) == ?2;
            },

        );
        test(
            "'remove_key' Tests",
            func() {


                let mem = Lib.get_new_memory_storage(8);
                let hashList = LibMemoryHashList.libMemoryHashList(mem);

                let key1 : Blob = Lib.Blobify.Text.to_blob("key1");
                let key2 : Blob = Lib.Blobify.Text.to_blob("key2");

                ignore hashList.add(key1, ownType1Blob);
                ignore hashList.add(key1, ownType1Blob);
                ignore hashList.add(key1, ownType2Blob);
                ignore hashList.add(key1, ownType3Blob);

                ignore hashList.add(key2, ownType1Blob);
                ignore hashList.add(key2, ownType2Blob);
                ignore hashList.add(key2, ownType3Blob);

                hashList.remove_key(key2);

                assert hashList.get_last_index(key1) == ?3;
                assert hashList.get_last_index(key2) == null;

                assert hashList.get_at_index(key2, 0) == null;
            },

        );

        test(
            "'remove_key' - with using collisions - Tests",
            func() {


                let mem = Lib.get_new_memory_storage(8);
                let hashList = LibMemoryHashList.libMemoryHashList(mem);

                // set own hashing-function for key->hash , so that hash-collisions will be forced
                hashList.setBlobHashingFunction(
                    func blobHash(n : Blob) : Nat32 {
                        5;
                    }
                );

                let key1 : Blob = Lib.Blobify.Text.to_blob("key1");
                let key2 : Blob = Lib.Blobify.Text.to_blob("key2");

                ignore hashList.add(key1, ownType1Blob);
                ignore hashList.add(key1, ownType1Blob);
                ignore hashList.add(key1, ownType2Blob);
                ignore hashList.add(key1, ownType3Blob);

                ignore hashList.add(key2, ownType1Blob);
                ignore hashList.add(key2, ownType2Blob);
                ignore hashList.add(key2, ownType3Blob);

                hashList.remove_key(key2);

                assert hashList.get_last_index(key1) == ?3;
                assert hashList.get_last_index(key2) == null;

                assert hashList.get_at_index(key2, 0) == null;
            },

        );

        test(
            "hash collisions Tests",
            func() {

                let mem = Lib.get_new_memory_storage(8);
                let hashList = LibMemoryHashList.libMemoryHashList(mem);

                // set own hashing-function for key->hash , so that hash-collisions will be forced
                hashList.setBlobHashingFunction(func blobHash(n : Blob) : Nat32 { 5 });

                let libKey = LibKey.libKey(mem);
                libKey.setBlobHashingFunction(func blobHash(n : Blob) : Nat32 { 5 });

                let key1 : Blob = Lib.Blobify.Text.to_blob("key1");
                let key2 : Blob = Lib.Blobify.Text.to_blob("key2");
                let key3 : Blob = Lib.Blobify.Text.to_blob("key3");

                ignore hashList.add(key1, ownType1Blob);
                ignore hashList.add(key1, ownType1Blob);
                ignore hashList.add(key1, ownType2Blob);
                ignore hashList.add(key1, ownType3Blob);

                ignore hashList.add(key2, ownType3Blob);
                ignore hashList.add(key2, ownType2Blob);
                ignore hashList.add(key2, ownType1Blob);

                let valsForKey1 : List.List<Nat64> = libKey.get_vals_for_key("key1");
                // two values should be stored for the key, because of hash collisions
                assert List.size(valsForKey1) == 2;

                let valsForKey2 : List.List<Nat64> = libKey.get_vals_for_key("key2");
                // two values should be stored for the key, because of hash collisions
                assert List.size(valsForKey2) == 2;

                let valsForKey3 : List.List<Nat64> = libKey.get_vals_for_key("key3");
                // two values should be stored for the not existing key, because of hash collisions
                assert List.size(valsForKey3) == 2;

                assert hashList.get_at_index(key1, 0) == ?ownType1Blob;

                assert hashList.get_at_index(key2, 0) == ?ownType3Blob;

                assert hashList.get_at_index(key3, 0) == null;

            },

        );

        test(
            "doing many different operations Tests",
            func() {
 
        
                let seed = 123456789;
                var fuzz = Fuzz.fromSeed(seed);

                let mem = Lib.get_new_memory_storage(0);
                let hashList = LibMemoryHashList.libMemoryHashList(mem);

                let key1 : Blob = Lib.Blobify.Text.to_blob("key1");
                let key2 : Blob = Lib.Blobify.Text.to_blob("key2");
                let key3 : Blob = Lib.Blobify.Text.to_blob("key3");

                let vec1 = VectorHelper.vectorHelper();
                let vec2 = VectorHelper.vectorHelper();
                let vec3 = VectorHelper.vectorHelper();

                let possibleValues : Vector.Vector<Blob> = Vector.new();

                // create 255 OwnType-types as blobs with random field values
                for (index in Iter.range(0, 255)) {

                    let dynamicType : OwnType = {
                        myNumber : Nat = fuzz.nat.randomRange(0, 125554);
                        myText : Text = fuzz.text.randomAlphabetic(fuzz.nat.randomRange(0, 20));
                    };

                    Vector.add(possibleValues, to_candid (dynamicType));
                };

                let isEqual = func checkForEqual(hashList : LibMemoryHashList.libMemoryHashList, vec : VectorHelper.vectorHelper, key : Blob) : Bool {

                    let lastIndexOrNull = hashList.get_last_index(key);
                    switch (lastIndexOrNull) {
                        case (?lastIndex) {
                            for (indexToUse in Iter.range(0, lastIndex)) {
                                let actualBlob : ?Blob = hashList.get_at_index(key, indexToUse);
                                let refBlob : ?Blob = vec.get_value(indexToUse);
                                if (actualBlob != refBlob) {
                                    return false;
                                };
                            };

                        };
                        case (_) {

                            let vectorIndexOrNull : ?Nat = vec.get_last_index();
                            switch (vectorIndexOrNull) {
                                case (?hasIndex) {
                                    return false;
                                };
                                case (_) {
                                    return true;
                                };
                            };
                        };
                    };

                    return true;

                };

                for (index in Iter.range(0, 12000)) {
                    let randomOperation : Nat = fuzz.nat.randomRange(0, 7);
                   
                    let randomKeyNumber = fuzz.nat.randomRange(0, 2);
                    var randomKey = key1;
                    var refVector = vec1;
                    if (randomKeyNumber == 1) {
                        randomKey := key2;
                        refVector := vec2;
                    } else if (randomKeyNumber == 2) {
                        randomKey := key3;
                        refVector := vec3;
                    };

                    switch (randomOperation) {
                        case (0) {
                            // get_at_index
                            let randomIndex = fuzz.nat.randomRange(0, 20);
                            let actualResult : ?Blob = hashList.get_at_index(randomKey, randomIndex);
                            let expectedResult : ?Blob = refVector.get_value(randomIndex);
                            assert actualResult == expectedResult;

                            assert isEqual(hashList, refVector, randomKey) == true;

                        };
                       
                        case (1 or 2 or 3) {
                            //add
                           
                            let randNumber = fuzz.nat.randomRange(0, 255);
                            
                            let randomBlob : Blob = Vector.get(possibleValues, randNumber);
                            
                            refVector.add(randomBlob);
                           
                            ignore hashList.add(randomKey, randomBlob);
                            
                            assert isEqual(hashList, refVector, randomKey) == true;
                           
                        };
                        case (4) {
                            // update at index
                            let randomIndex = fuzz.nat.randomRange(0, 20);
                            let randomBlob : Blob = Vector.get(possibleValues, fuzz.nat.randomRange(0, 255));
                            refVector.update_at_index(randomIndex, randomBlob);
                            ignore hashList.update_at_index(randomKey, randomIndex, randomBlob);

                            assert isEqual(hashList, refVector, randomKey) == true;
                        };
                        case (5) {
                            
                            // remove value at index
                            let randomIndex = fuzz.nat.randomRange(0, 20);
                            refVector.remove_at_index(randomIndex);
                            ignore hashList.remove_at_index(randomKey, randomIndex);

                            assert isEqual(hashList, refVector, randomKey) == true;

                        };
                         case (6) {
                            
                            // remove at range 
                                                        
                            let randomIndex = fuzz.nat.randomRange(0, 14);
                            let randomEndIndex = fuzz.nat.randomRange(0, 14);
                           
                            refVector.remove_at_range(randomIndex, randomEndIndex);
                          
                            ignore hashList.remove_at_range(randomKey, randomIndex, Option.make(randomEndIndex));

                            assert isEqual(hashList, refVector, randomKey) == true;

                        };
                        case (7) {
                            // insert at index
                            let randomIndex = fuzz.nat.randomRange(0, 20);
                            let randomBlob : Blob = Vector.get(possibleValues, fuzz.nat.randomRange(0, 255));

                            refVector.insert_at_index(randomIndex, randomBlob);
                            ignore hashList.insert_at_index(randomKey, randomIndex, randomBlob);
                            assert isEqual(hashList, refVector, randomKey) == true;

                        };
                        case (_) {
                            // do nothing
                        };
                    };
                };

                // Debug.print(debug_show (hashList.get_last_index(key1)));
                // Debug.print(debug_show (hashList.get_last_index(key2)));
                // Debug.print(debug_show (hashList.get_last_index(key3)));

                assert isEqual(hashList, vec1, key1) == true;
                assert isEqual(hashList, vec2, key2) == true;
                assert isEqual(hashList, vec3, key3) == true;

            },

        );

        test(
            "doing many different operations - with forced hash-collisions - Tests",
            func() {

return;

                let seed = 123456789;
                var fuzz = Fuzz.fromSeed(seed);

                let mem = Lib.get_new_memory_storage(8);
                let hashList = LibMemoryHashList.libMemoryHashList(mem);

                // set own hashing-function for key->hash , so that hash-collisions will be forced
                hashList.setBlobHashingFunction(
                    func blobHash(n : Blob) : Nat32 {
                        5;
                    }
                );

                let key1 : Blob = Lib.Blobify.Text.to_blob("key1");
                let key2 : Blob = Lib.Blobify.Text.to_blob("key2");
                let key3 : Blob = Lib.Blobify.Text.to_blob("key3");

                let vec1 = VectorHelper.vectorHelper();
                let vec2 = VectorHelper.vectorHelper();
                let vec3 = VectorHelper.vectorHelper();

                let possibleValues : Vector.Vector<Blob> = Vector.new();

                // create 255 OwnType-types as blobs with random field values
                for (index in Iter.range(0, 255)) {

                    let dynamicType : OwnType = {
                        myNumber : Nat = fuzz.nat.randomRange(0, 125554);
                        myText : Text = fuzz.text.randomAlphabetic(fuzz.nat.randomRange(0, 20));
                    };

                    Vector.add(possibleValues, to_candid (dynamicType));
                };

                let isEqual = func checkForEqual(hashList : LibMemoryHashList.libMemoryHashList, vec : VectorHelper.vectorHelper, key : Blob) : Bool {

                    let lastIndexOrNull = hashList.get_last_index(key);
                    switch (lastIndexOrNull) {
                        case (?lastIndex) {
                            for (indexToUse in Iter.range(0, lastIndex)) {
                                let actualBlob : ?Blob = hashList.get_at_index(key, indexToUse);
                                let refBlob : ?Blob = vec.get_value(indexToUse);
                                if (actualBlob != refBlob) {
                                    return false;
                                };
                            };

                        };
                        case (_) {

                            let lastIndexOrNull : ?Nat = vec.get_last_index();
                            switch (lastIndexOrNull) {
                                case (?hasIndex) {
                                    return false;
                                };
                                case (_) {
                                    return true;
                                };
                            };
                        };
                    };

                    return true;

                };

                for (index in Iter.range(0, 12000)) {
                    let randomOperation : Nat = fuzz.nat.randomRange(0, 7);
                    // Debug.print("Random operation");
                    // Debug.print(debug_show(randomOperation));

                    let randomKeyNumber = fuzz.nat.randomRange(0, 2);
                    var randomKey = key1;
                    var refVector = vec1;
                    if (randomKeyNumber == 1) {
                        randomKey := key2;
                        refVector := vec2;
                    } else if (randomKeyNumber == 2) {
                        randomKey := key3;
                        refVector := vec3;
                    };

                    switch (randomOperation) {
                        case (0) {
                            // get_at_index
                            let randomIndex = fuzz.nat.randomRange(0, 20);
                            let actualResult : ?Blob = hashList.get_at_index(randomKey, randomIndex);
                            let expectedResult : ?Blob = refVector.get_value(randomIndex);
                            assert actualResult == expectedResult;

                            assert isEqual(hashList, refVector, randomKey) == true;

                        };
                        case (1 or 2 or 3) {
                            //add
                            let randomBlob : Blob = Vector.get(possibleValues, fuzz.nat.randomRange(0, 255));
                            refVector.add(randomBlob);
                            ignore hashList.add(randomKey, randomBlob);

                            assert isEqual(hashList, refVector, randomKey) == true;
                        };
                        case (4) {
                            // update at index
                            let randomIndex = fuzz.nat.randomRange(0, 20);
                            let randomBlob : Blob = Vector.get(possibleValues, fuzz.nat.randomRange(0, 255));
                            refVector.update_at_index(randomIndex, randomBlob);
                            ignore hashList.update_at_index(randomKey, randomIndex, randomBlob);

                            assert isEqual(hashList, refVector, randomKey) == true;
                        };
                        case (5) {
                            // remove value at index
                            let randomIndex = fuzz.nat.randomRange(0, 20);
                            refVector.remove_at_index(randomIndex);
                            ignore hashList.remove_at_index(randomKey, randomIndex);

                            assert isEqual(hashList, refVector, randomKey) == true;

                        };
                        case (6) {
                            
                            // remove at range 
                                                        
                            let randomIndex = fuzz.nat.randomRange(0, 14);
                            let randomEndIndex = fuzz.nat.randomRange(0, 14);
                           
                            refVector.remove_at_range(randomIndex, randomEndIndex);
                          
                            ignore hashList.remove_at_range(randomKey, randomIndex, Option.make(randomEndIndex));

                            assert isEqual(hashList, refVector, randomKey) == true;

                        };
                         case (7) {
                            // insert at index
                            let randomIndex = fuzz.nat.randomRange(0, 20);
                            let randomBlob : Blob = Vector.get(possibleValues, fuzz.nat.randomRange(0, 255));

                            refVector.insert_at_index(randomIndex, randomBlob);
                            ignore hashList.insert_at_index(randomKey, randomIndex, randomBlob);
                            assert isEqual(hashList, refVector, randomKey) == true;

                        };
                        case (_) {
                            // do nothing
                        };
                    };
                };

                // Debug.print(debug_show (hashList.get_last_index(key1)));
                // Debug.print(debug_show (hashList.get_last_index(key2)));
                // Debug.print(debug_show (hashList.get_last_index(key3)));

                assert isEqual(hashList, vec1, key1) == true;
                assert isEqual(hashList, vec2, key2) == true;
                assert isEqual(hashList, vec3, key3) == true;

            },

        );

    },
);
