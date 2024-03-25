import Debug "mo:base/Debug";
import lib "../src/lib";
import Blob "mo:base/Blob";
import Text "mo:base/Text";
import Iter "mo:base/Iter";
import Vector "mo:vector";

actor{

    Debug.print("hello world");
    stable var mem = lib.get_new_memory_storage(8);
    let hashList = lib.MemoryHashList(mem);
     

     public shared query func show():async [?Text]{

        let key = lib.Blobify.Text.to_blob("key1");

        let result:Vector.Vector<?Text> = Vector.new();
        

        for(i in Iter.range(0,5)){
            let valueOrNull:?Blob = hashList.get_at_index(key, i);
            switch(valueOrNull){
                case (?value){
                    let text:Text = lib.Blobify.Text.from_blob(value);
                    Vector.add<?Text>(result,?text);
                };
                case (_){
                    Vector.add<?Text>(result, null);
                };
            };            
        };
        
        return Vector.toArray(result);
        
        
     };

     public shared func add5(val:Text):async (){
        let blob:Blob = lib.Blobify.Text.to_blob(val);
        let key = lib.Blobify.Text.to_blob("key1");
        ignore hashList.add(key, blob);
     };

      public shared func add6(val:Text):async (){
        let blob:Blob = lib.Blobify.Text.to_blob(val);
        let key = lib.Blobify.Text.to_blob("key1");
        ignore lib.StableMemoryHashList.add(mem, key, blob);        
     };

};
