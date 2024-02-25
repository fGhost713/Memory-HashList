// @testmode wasi
//import lib "../src/lib";
//import MemoryRegion "mo:memory-region";
import { MemoryRegion } "mo:memory-region";
import Blob "mo:base/Blob";
import CommonMemoryHashKeyList "../src/Helpers/commonMemoryHashKeyList";
import Region "mo:base/Region";
import Text "mo:base/Text";

import { test; suite } "mo:test";

  //let x= MemoryRegion.new();
//   actor {


//     public func bla(): async Text{

//         let hello = Region.new();
//         return "hello";
//     };

    suite(
    "HashList tests",
    func(){
        test(
            "Add item",
            func (){

                let hello = Region.new();
                assert 1 == 1;
            },

        );

    }
    
// func singleBlob_Add_Entries_Test(){

//   assert 1 == 1;

//   //let dbItem = lib.getNewMemoryStorage();
//   let x:MemoryRegion.MemoryRegion = MemoryRegion.new();
// };

// func bla( what:Any){
//    let x:Blob = to_candid(what);

// };

// singleBlob_Add_Entries_Test();

// assert add(1, 2) == 3;
// assert add(3, 22) == 25;


);

  //};