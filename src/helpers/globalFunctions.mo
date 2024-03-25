import Blob "mo:base/Blob";
import Nat64 "mo:base/Nat64";
import Debug "mo:base/Debug";
import Option "mo:base/Option";
import CommonTypes "../types/commonTypes";
import { MemoryRegion } "mo:memory-region";

module {

    public func nat32Identity(n : Nat32) : Nat32 {
        return n;
    };

    public func blobHash(n : Blob) : Nat32 {
        Blob.hash(n);
    };

    // Make sure we only deallocate memory-space that we have already allocated.
    // This is to ensure that not wrong memory is deallocated
    public func deallocate(mem : CommonTypes.MemoryStorage, address : Nat64, size : Nat64) {

        let end : Nat64 = address + size;
        switch(mem.memory_used_firstAddress){
            case (?memUsedFirstAddress){
                if (address >= memUsedFirstAddress) {
                    if (end <= mem.memory_used_lastAddress) {

                        MemoryRegion.deallocate(mem.memory_region, Nat64.toNat(address), Nat64.toNat(size));

                        if (address == memUsedFirstAddress) {
                            mem.memory_used_firstAddress := Option.make(memUsedFirstAddress + size);
                        };

                        if (mem.memory_used_lastAddress == end) {
                            mem.memory_used_lastAddress := mem.memory_used_lastAddress - size;
                        };
                    };
                };

            };
            case (_){
                
            };
        };
        
    };

    // Allocate memory and updates the memory-bound variables
    public func allocate(mem : CommonTypes.MemoryStorage, size : Nat64) : Nat {

        let allocatedAddress : Nat = MemoryRegion.allocate(mem.memory_region, Nat64.toNat(size));
        let allocatedAddressNat64 : Nat64 = Nat64.fromNat(allocatedAddress);
        let end : Nat64 = allocatedAddressNat64 + size;

         switch(mem.memory_used_firstAddress){
            case (?memUsedFirstAddress){
                if (memUsedFirstAddress > allocatedAddressNat64) {
                    mem.memory_used_firstAddress := Option.make(allocatedAddressNat64);
                }  
            };
            case (_){
                mem.memory_used_firstAddress := Option.make(allocatedAddressNat64);
            };
         };
       

        if (mem.memory_used_lastAddress < end) {
            mem.memory_used_lastAddress := end;
        };
        return allocatedAddress;
    };

};
