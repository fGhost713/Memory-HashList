import Nat32 "mo:base/Nat32";
import Blob "mo:base/Blob";
import Option "mo:base/Option";
import Array "mo:base/Array";
import Nat64 "mo:base/Nat64";


module{

    public func nat32Identity(n : Nat32) : Nat32 { 
        return n 
    };

    public func blobHash(n:Blob):Nat32{
         Blob.hash(n);
    };
};