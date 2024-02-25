import StableTrieMap "mo:StableTrieMap";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Text "mo:base/Text";
import Region "mo:base/Region";
import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import List "mo:base/List";
import Hash "mo:base/Hash";
import Nat8 "mo:base/Nat8";
import Principal "mo:base/Principal";
import Itertools "mo:itertools/Iter";
import { MemoryRegion }  "mo:memory-region";
import lib "../lib";
import CommonMemoryHashKeyList "../Helpers/commonMemoryHashKeyList";

actor {

  public query func greet(name : Text) : async Text {
    return "Hello, " # name # "!";
  };


  let dbItem:CommonMemoryHashKeyList.MemoryStorage= lib.getNewMemoryStorage();
  Debug.print("skkjd");
  Debug.print(debug_show(dbItem.memory_region.size));

};
