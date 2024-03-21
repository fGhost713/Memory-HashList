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
import StableTrieMap "mo:StableTrieMap";
import Vector "mo:vector";
import { test; suite } "mo:test";
import LibIndex "../src/modules/libIndex";

let globalBlobHashFunction = GlobalFunctions.blobHash;
let dummyBlob : Blob = lib.Blobify.Text.to_blob("dummyBlob");
let dummyNat32 : Nat32 = 732354;

suite(
    "LibIndex Tests",
    func() {
        test(
            "Testing common LibIndex functions",
            func() {

                let mem = lib.get_new_memory_storage(8);
                let libIndex= LibIndex.libIndex(mem);

                let index0 = libIndex.add_outer_vector();
                let index1 = libIndex.add_outer_vector();
                let index2 = libIndex.add_outer_vector();

                assert index0 == 0;
                assert index1 == 1;

                var val = libIndex.get_address_of_last_stored_wrapped_blob(0);
                assert val == null;

                val := libIndex.get_address_of_last_stored_wrapped_blob(10);
                assert val == null;

                libIndex.append_wrapped_blob_memory_address(0, 5);
                libIndex.append_wrapped_blob_memory_address(0, 6);

                libIndex.append_wrapped_blob_memory_address(1, 11);

                assert libIndex.get_last_index(0) == ?1;
                assert libIndex.get_last_index(1) == ?0;
                assert libIndex.get_last_index(2) == null;

                libIndex.insert_at_index(0,0, 3);
                libIndex.insert_at_index(0,1, 4);

                assert libIndex.get_wrapped_blob_Address(0,0) == ?3;
                assert libIndex.get_wrapped_blob_Address(0,1) == ?4;
                assert libIndex.get_wrapped_blob_Address(0,2) == ?5;
                assert libIndex.get_wrapped_blob_Address(0,3) == ?6;

                let bla = libIndex.get_address_of_last_stored_wrapped_blob(0);
                assert libIndex.get_address_of_last_stored_wrapped_blob(0) == ?6;

                assert libIndex.remove_last_element(0) == ?6;
                assert libIndex.get_address_of_last_stored_wrapped_blob(0) == ?5;
                libIndex.append_wrapped_blob_memory_address(0,6);

                libIndex.append_wrapped_blob_memory_address(0, 23);
                assert libIndex.get_address_of_last_stored_wrapped_blob(0) == ?23;

                libIndex.remove_at_index(0,0);
                assert libIndex.get_wrapped_blob_Address(0,0) == ?4;
                assert libIndex.get_wrapped_blob_Address(0,1) == ?5;
                assert libIndex.get_wrapped_blob_Address(0,2) == ?6;
                assert libIndex.get_wrapped_blob_Address(0,3) == ?23;

                libIndex.remove_at_index(0,1);
                assert libIndex.get_wrapped_blob_Address(0,0) == ?4;
                assert libIndex.get_wrapped_blob_Address(0,1) == ?6;
                assert libIndex.get_wrapped_blob_Address(0,2) == ?23;

                libIndex.remove_at_index(0,2);
                assert libIndex.get_wrapped_blob_Address(0,0) == ?4;
                assert libIndex.get_wrapped_blob_Address(0,1) == ?6;
                assert libIndex.get_wrapped_blob_Address(0,2) == null;
                assert libIndex.get_address_of_last_stored_wrapped_blob(0) == ?6;
  
                libIndex.empty_inner_vector(0);
                assert libIndex.get_wrapped_blob_Address(0,0) == null;
                assert libIndex.get_wrapped_blob_Address(0,1) == null;
                assert libIndex.get_wrapped_blob_Address(0,2) == null;
                assert libIndex.get_address_of_last_stored_wrapped_blob(0) == null;
                assert libIndex.get_last_index(0) == null;


                assert libIndex.is_free_vector_available() == true;
                assert Vector.get(mem.indizesPerKey_free,0) == 0;

                let index0New = libIndex.add_outer_vector();
                assert index0New == 0;

                libIndex.insert_at_index(0,1, 11);
                libIndex.insert_at_index(0,0, 5);
                libIndex.insert_at_index(0,0, 2);
                assert libIndex.get_wrapped_blob_Address(0,0) == ?2;
                assert libIndex.get_wrapped_blob_Address(0,1) == ?5;

                libIndex.empty_inner_vector(0);
                libIndex.insert_at_index(0,0, 5);
                libIndex.insert_at_index(0,1, 2);
                assert libIndex.get_wrapped_blob_Address(0,0) == ?5;
                assert libIndex.get_wrapped_blob_Address(0,1) == null;
            },

        );

        test(
            "Testing insertAt and deleteAt with 20 million entries",
            func() {

                let mem = lib.get_new_memory_storage(8);
                let libIndex= LibIndex.libIndex(mem);

                let index0 = libIndex.add_outer_vector();
                let index1 = libIndex.add_outer_vector();
                let index2 = libIndex.add_outer_vector();

                for(index in Iter.range(0, 20_000_000)){
                    let valueToAdd:Nat64 = Nat64.fromNat(index);
                    libIndex.append_wrapped_blob_memory_address(0, valueToAdd);
                };

                libIndex.insert_at_index(0,1, 555);
                libIndex.insert_at_index(0,999_900, 777);

                libIndex.remove_at_index(0,5);
                libIndex.remove_at_index(0,999_999);

                assert libIndex.get_wrapped_blob_Address(0,0) == ?0;
                assert libIndex.get_wrapped_blob_Address(0,1) == ?555;

                assert libIndex.get_wrapped_blob_Address(0,4) == ?3;
                assert libIndex.get_wrapped_blob_Address(0,5) == ?5;

                assert libIndex.get_wrapped_blob_Address(0,999_900-1) == ?777;
             
               

            },

        );
        
    },
);
