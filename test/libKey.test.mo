// @testmode wasi
import lib "../src/lib";
import Blob "mo:base/Blob";
import Iter "mo:base/Iter";
import Nat64 "mo:base/Nat64";
import List "mo:base/List";
import Nat32 "mo:base/Nat32";
import LibKey "../src/modules/libKey";
import GlobalFunctions "../src/helpers/globalFunctions";
import { test; suite } "mo:test";

let globalBlobHashFunction = GlobalFunctions.blobHash;

suite(
    "LibKey Tests",
    func() {
        test(
            "Test 'add_entry' function",
            func() {

                let mem = lib.get_new_memory_storage(8);
                let libKey = LibKey;

                let key1 : Blob = lib.Blobify.Text.to_blob("key1");
                let key2 : Blob = lib.Blobify.Text.to_blob("key2");

                var hashedKey1 : Nat32 = globalBlobHashFunction(key1);
                var hashedKey2 : Nat32 = globalBlobHashFunction(key2);

                libKey.add_entry(mem,hashedKey1, 1);
                libKey.add_entry(mem,hashedKey2, 2);

                let result1 = libKey.get_values(mem,hashedKey1);
                let result2 = libKey.get_values(mem,hashedKey2);

                assert List.size(result1) == 1;

                assert List.size(result2) == 1;

                assert List.toArray(result1) == [1];

                assert List.toArray(result2) == [2];

            },

        );
        test(
            "Test 'add_entry' function with mutiple values + 'get_key_hashes' function",
            func() {

                let mem = lib.get_new_memory_storage(8);
                let libKey = LibKey;
                let key1 : Blob = lib.Blobify.Text.to_blob("key1");
                var hashedKey1 : Nat32 = globalBlobHashFunction(key1);

                libKey.add_entry(mem,hashedKey1, 1);
                libKey.add_entry(mem,hashedKey1, 1);
                libKey.add_entry(mem,hashedKey1, 1);

                libKey.add_entry(mem,hashedKey1, 2);
                libKey.add_entry(mem,hashedKey1, 3);

                let result1 = libKey.get_values(mem,hashedKey1);

                assert List.size(result1) == 3;
                assert List.toArray(List.reverse(result1)) == [1, 2, 3];

                let keys = libKey.get_key_hashes(mem);
                assert Iter.toArray(keys) == [hashedKey1];

            },

        );

        test(
            "Test 'remove_value' function",
            func() {

                let mem = lib.get_new_memory_storage(8);
                let libKey = LibKey;

                let key1 : Blob = lib.Blobify.Text.to_blob("key1");
                let key2 : Blob = lib.Blobify.Text.to_blob("key2");

                var hashedKey1 : Nat32 = globalBlobHashFunction(key1);
                var hashedKey2 : Nat32 = globalBlobHashFunction(key2);

                libKey.add_entry(mem,hashedKey1, 1);
                libKey.add_entry(mem,hashedKey1, 2);
                libKey.add_entry(mem,hashedKey2, 3);

                libKey.remove_value(mem,hashedKey1, 2);

                libKey.remove_value(mem,hashedKey2, 7); // value not exist
                libKey.remove_value(mem,hashedKey2, 3);

                let result1 = libKey.get_values(mem,hashedKey1);
                let result2 = libKey.get_values(mem,hashedKey2);

                assert List.size(result1) == 1;
                assert List.toArray(result1) == [1];

                assert List.size(result2) == 0;

                let allKeysArray = Iter.toArray(libKey.get_key_hashes(mem));
                assert allKeysArray == [hashedKey1];

                let vals_for_key1 : List.List<Nat64> = libKey.get_vals_for_key(mem,key1);
                let vals_for_key2 : List.List<Nat64> = libKey.get_vals_for_key(mem,key2);

                assert List.toArray(vals_for_key1) == [1];
                assert List.size(vals_for_key2) == 0;

            },

        );
    },
);
