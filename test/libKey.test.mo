// @testmode wasi
import lib "../src/lib";
import Blob "mo:base/Blob";
import Text "mo:base/Text";
import Option "mo:base/Option";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";
import Nat64 "mo:base/Nat64";
import List "mo:base/List";
import Array "mo:base/Array";
import Nat32 "mo:base/Nat32";
import LibKey "../src/modules/libKey";
import GlobalFunctions "../src/helpers/globalFunctions";

import { test; suite } "mo:test";

let globalBlobHashFunction = GlobalFunctions.blobHash;
let dummyBlob : Blob = lib.Blobify.Text.to_blob("dummyBlob");
let dummyNat32 : Nat32 = 732354;

suite(
    "LibKey Tests",
    func() {
        test(
            "Test 'add_entry' function",
            func() {

                let libKey = LibKey.libKey(lib.get_new_memory_storage(8));

                let key1 : Blob = lib.Blobify.Text.to_blob("key1");
                let key2 : Blob = lib.Blobify.Text.to_blob("key2");

                var hashedKey1 : Nat32 = globalBlobHashFunction(key1);
                var hashedKey2 : Nat32 = globalBlobHashFunction(key2);

                libKey.add_entry(hashedKey1, 1);
                libKey.add_entry(hashedKey2, 2);

                let result1 = libKey.get_values(hashedKey1);
                let result2 = libKey.get_values(hashedKey2);

                assert List.size(result1) == 1;

                assert List.size(result2) == 1;

                assert List.toArray(result1) == [1];

                assert List.toArray(result2) == [2];

            },

        );
        test(
            "Test 'add_entry' function with mutiple values + 'get_key_vals' function",
            func() {

                let libKey = LibKey.libKey(lib.get_new_memory_storage(8));
                let key1 : Blob = lib.Blobify.Text.to_blob("key1");
                var hashedKey1 : Nat32 = globalBlobHashFunction(key1);

                libKey.add_entry(hashedKey1, 1);
                libKey.add_entry(hashedKey1, 1);
                libKey.add_entry(hashedKey1, 1);

                libKey.add_entry(hashedKey1, 2);
                libKey.add_entry(hashedKey1, 3);

                let result1 = libKey.get_values(hashedKey1);

                assert List.size(result1) == 3;
                assert List.toArray(List.reverse(result1)) == [1, 2, 3];

                let keys = libKey.get_key_vals();
                assert Iter.toArray(keys) == [hashedKey1];

            },

        );
        test(
            "Test 'add_entry' function with hash collision",
            func() {

                let dummyBlobToNat32Function = func(n : Blob) : Nat32 {
                    dummyNat32;
                };
                let libKey = LibKey.libKey(lib.get_new_memory_storage(8));

                libKey.setBlobHashingFunction(dummyBlobToNat32Function);

                let key1 : Blob = lib.Blobify.Text.to_blob("key1");
                let key2 : Blob = lib.Blobify.Text.to_blob("key2");
                let key3 : Blob = lib.Blobify.Text.to_blob("key3");

                var hashedKey1 : Nat32 = dummyBlobToNat32Function(key1);
                var hashedKey2 : Nat32 = dummyBlobToNat32Function(key2);
                var hashedKey3 : Nat32 = dummyBlobToNat32Function(key3);

                libKey.add_entry(hashedKey1, 1);
                libKey.add_entry(hashedKey1, 1);
                libKey.add_entry(hashedKey2, 2);
                libKey.add_entry(hashedKey3, 3);

                let result1 = libKey.get_values(hashedKey1);
                let result2 = libKey.get_values(hashedKey2);
                let result3 = libKey.get_values(hashedKey3);

                assert List.size(result1) == 3;
                assert List.size(result2) == 3;
                assert List.size(result3) == 3;

                assert result1 == result2;
                assert result2 == result3;

                assert List.toArray(List.reverse(result1)) == [1, 2, 3];

                let valsForKey : List.List<Nat64> = libKey.get_vals_for_key(key2);

                assert valsForKey == result1;

            },

        );

        test(
            "Test 'remove_value' function",
            func() {

                let libKey = LibKey.libKey(lib.get_new_memory_storage(8));

                let key1 : Blob = lib.Blobify.Text.to_blob("key1");
                let key2 : Blob = lib.Blobify.Text.to_blob("key2");

                var hashedKey1 : Nat32 = globalBlobHashFunction(key1);
                var hashedKey2 : Nat32 = globalBlobHashFunction(key2);

                libKey.add_entry(hashedKey1, 1);
                libKey.add_entry(hashedKey1, 2);
                libKey.add_entry(hashedKey2, 3);

                libKey.remove_value(hashedKey1, 2);

                libKey.remove_value(hashedKey2, 7); // value not exist
                libKey.remove_value(hashedKey2, 3);

                let result1 = libKey.get_values(hashedKey1);
                let result2 = libKey.get_values(hashedKey2);

                assert List.size(result1) == 1;
                assert List.toArray(result1) == [1];

                assert List.size(result2) == 0;

                let allKeysArray = Iter.toArray(libKey.get_key_vals());
                assert allKeysArray == [hashedKey1];

                let vals_for_key1 : List.List<Nat64> = libKey.get_vals_for_key(key1);
                let vals_for_key2 : List.List<Nat64> = libKey.get_vals_for_key(key2);

                assert List.toArray(vals_for_key1) == [1];
                assert List.size(vals_for_key2) == 0;

            },

        );
    },
);
