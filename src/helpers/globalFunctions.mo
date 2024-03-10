import Nat32 "mo:base/Nat32";
import Blob "mo:base/Blob";



module{

    public func nat32Identity(n : Nat32) : Nat32 { 
        return n 
    };

    public func blobHash(n:Blob):Nat32{
         Blob.hash(n);
    };

};