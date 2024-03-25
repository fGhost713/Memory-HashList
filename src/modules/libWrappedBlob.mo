import Blob "mo:base/Blob";
import Nat64 "mo:base/Nat64";
import Region "mo:base/Region";
import Option "mo:base/Option";
import Debug "mo:base/Debug";
import Nat16 "mo:base/Nat16";
import Nat32 "mo:base/Nat32";
import CommonTypes "../types/commonTypes";
import MemoryStorageTypes "../types/memoryStorage/memoryStorageTypes";
import GlobalFunctions "../helpers/globalFunctions";

module {

    private let offsets = CommonTypes.Offsets_WrappedBlob;

    // returns the internal blob size in bytes
    public func get_internal_blob_size_from_address(memoryStorage : MemoryStorageTypes.MemoryStorage, memoryAddress : Nat64) : Nat32 {
        Region.loadNat32(memoryStorage.memory_region.region, memoryAddress + offsets.internalBlobSize);
    };

    // set the internal blob size
    public func set_internal_blob_size(memoryStorage : MemoryStorageTypes.MemoryStorage, memoryAddress : Nat64, blobSize : Nat32) {
        Region.storeNat32(memoryStorage.memory_region.region, memoryAddress + offsets.internalBlobSize, blobSize);
    };

    // returns the allocated size for the internal blob
    public func get_internal_blob_allocated_size_from_address(memoryStorage : MemoryStorageTypes.MemoryStorage, memoryAddress : Nat64) : Nat32 {
        Region.loadNat32(memoryStorage.memory_region.region, memoryAddress + offsets.internalBlobAllocatedSize);
    };

    // set the allocated size for the internal blob
    public func set_internal_blob_allocated_size(memoryStorage : MemoryStorageTypes.MemoryStorage, memoryAddress : Nat64, allocatedBlobSize : Nat32) {
        Region.storeNat32(memoryStorage.memory_region.region, memoryAddress + offsets.internalBlobAllocatedSize, allocatedBlobSize);
    };

    // returns the related memory address where the internal blob is stored
    public func get_memory_address_of_internal_blob(memoryStorage : MemoryStorageTypes.MemoryStorage, memoryAddress : Nat64) : Nat64 {
        Region.loadNat64(memoryStorage.memory_region.region, memoryAddress + offsets.internalBlobAddress);
    };

    // set the related memory address where the internal blob is stored
    public func set_memory_address_of_internal_blob(memoryStorage : MemoryStorageTypes.MemoryStorage, memoryAddress : Nat64, internalBlobAddress : Nat64) {
        Region.storeNat64(memoryStorage.memory_region.region, memoryAddress + offsets.internalBlobAddress, internalBlobAddress);
    };

    // returns the identifier-value stored in memory
    public func get_identifier(memoryStorage : MemoryStorageTypes.MemoryStorage, memoryAddress : Nat64) : Nat64 {
        Region.loadNat64(memoryStorage.memory_region.region, memoryAddress + offsets.identifier);
    };

    // set the identifier-value stored in memory to the default wrappedBlob-identifier value
    public func set_identifier(memoryStorage : MemoryStorageTypes.MemoryStorage, memoryAddress : Nat64) {
        Region.storeNat64(memoryStorage.memory_region.region, memoryAddress + offsets.identifier, CommonTypes.identifier_WrappedBlob);
    };

    // the identifier is set to zero on the related memory-position
    public func remove_identifier(memoryStorage : MemoryStorageTypes.MemoryStorage, memoryAddress : Nat64) {
        Region.storeNat64(memoryStorage.memory_region.region, memoryAddress + offsets.identifier, 0);
    };

    // returns if wrapped-blob (type) is stored in the memory-address
    public func is_wrapped_blob_on_address(memoryStorage : MemoryStorageTypes.MemoryStorage, memoryAddress : Nat64) : Bool {
        let ident = get_identifier(memoryStorage, memoryAddress);
        return ident == CommonTypes.identifier_WrappedBlob;
    };

    // returns the version-number
    public func get_version(memoryStorage : MemoryStorageTypes.MemoryStorage, memoryAddress : Nat64) : Nat16 {
        Region.loadNat16(memoryStorage.memory_region.region, memoryAddress + offsets.version);
    };

    // sets the version to the curent latest version number
    public func set_version(memoryStorage : MemoryStorageTypes.MemoryStorage, memoryAddress : Nat64) {
        Region.storeNat16(memoryStorage.memory_region.region, memoryAddress + offsets.version, CommonTypes.version);
    };

    // returns the inner-blob from memory
    public func get_inner_blob_from_wrapped_blob_Address(memoryStorage : MemoryStorageTypes.MemoryStorage, memoryAddress : Nat64) : ?Blob {

        if (is_wrapped_blob_on_address(memoryStorage, memoryAddress) == false) {
            return null;
        };
        let blobSize : Nat32 = get_internal_blob_size_from_address(memoryStorage, memoryAddress);
        let internalBlobAddress : Nat64 = get_memory_address_of_internal_blob(memoryStorage, memoryAddress);
        let result = Region.loadBlob(memoryStorage.memory_region.region, internalBlobAddress, Nat32.toNat(blobSize));
        return Option.make(result);
    };

    // returns true if deleted, otherwise false is returned
    public func delete_wrapped_blob(memoryStorage : MemoryStorageTypes.MemoryStorage, wrappedBlobAddress : Nat64) : Bool {

        if (is_wrapped_blob_on_address(memoryStorage, wrappedBlobAddress) == false) {
            return false;
        };

        let allocatedInnerBlobSize : Nat32 = get_internal_blob_allocated_size_from_address(memoryStorage, wrappedBlobAddress);
        let innerBlobAddress : Nat64 = get_memory_address_of_internal_blob(memoryStorage, wrappedBlobAddress);

        // deallocate internal blob
        GlobalFunctions.deallocate(memoryStorage, innerBlobAddress, Nat64.fromNat32(allocatedInnerBlobSize));

        // remove identifier
        remove_identifier(memoryStorage, wrappedBlobAddress);

        // deallocate wrapped-blob
        GlobalFunctions.deallocate(memoryStorage, wrappedBlobAddress, offsets.bytesNeeded);

        return true;

    };

    // returns true if update was successfull
    public func update_inner_blob(memoryStorage : MemoryStorageTypes.MemoryStorage, wrappedBlobAddress : Nat64, newBlobToStore : Blob) : Bool {

        if (is_wrapped_blob_on_address(memoryStorage, wrappedBlobAddress) == false) {
            return false;
        };

        let newBlobSize : Nat = newBlobToStore.size();
        let newBlobSizeNat32 : Nat32 = Nat32.fromNat(newBlobSize);
        let oldBlobAddress : Nat64 = get_memory_address_of_internal_blob(memoryStorage, wrappedBlobAddress);

        let allocatedSize : Nat32 = get_internal_blob_allocated_size_from_address(memoryStorage, wrappedBlobAddress);
        if (newBlobSizeNat32 <= allocatedSize) {
            // we can directly overwrite the previous blob in memory

            // set the new size
            set_internal_blob_size(memoryStorage, wrappedBlobAddress, newBlobSizeNat32);

            // overwrite old blob with new blob
            Region.storeBlob(memoryStorage.memory_region.region, oldBlobAddress, newBlobToStore);

        } else {
            // we need to delete old internal-blob memory and reallocate new memory + store the updated blob

            // deallocate the old blob
            GlobalFunctions.deallocate(memoryStorage, oldBlobAddress, Nat64.fromNat32(allocatedSize));

            // allocate new memory space
            let allocatedSizeForUpdatedBlob = newBlobSize + Nat32.toNat(memoryStorage.replaceBufferSize);
            let newInternalBlobAddress = GlobalFunctions.allocate(memoryStorage, Nat64.fromNat(allocatedSizeForUpdatedBlob));

            // store the updated blob
            Region.storeBlob(memoryStorage.memory_region.region, Nat64.fromNat(newInternalBlobAddress), newBlobToStore);

            // store the address of the updated blob
            set_memory_address_of_internal_blob(memoryStorage, wrappedBlobAddress, Nat64.fromNat(newInternalBlobAddress));

            // store the allocated-size-value
            set_internal_blob_allocated_size(memoryStorage, wrappedBlobAddress, Nat32.fromNat(allocatedSizeForUpdatedBlob));

            // store the size of the updated blob
            set_internal_blob_size(memoryStorage, wrappedBlobAddress, newBlobSizeNat32);
        };

        return true;

    };

    // Create and store new wrappedBlob entry in memory.
    // -> The wrapped-Blob is written directly into memory.
    //    This means the actual blob for the type 'wrappedBlob'
    //    (defined in types/wrappedBlob/wrappedBlobTypes.mo') is not created.

    public func create_new(memoryStorage : MemoryStorageTypes.MemoryStorage, blobToStore : Blob) : Nat64 /* stored wrappedBlob address*/ {

        // allocate memory and get the memory address

        let memoryAddress = Nat64.fromNat(GlobalFunctions.allocate(memoryStorage, offsets.bytesNeeded));

        // Store the wrappedBlob info direct into memory.
        // (This is faster than create and save instance of 'wrappedBlob'-type into memory)

        // identifier
        Region.storeNat64(memoryStorage.memory_region.region, memoryAddress + offsets.identifier, CommonTypes.identifier_WrappedBlob);

        // version
        Region.storeNat16(memoryStorage.memory_region.region, memoryAddress + offsets.version, CommonTypes.version);

        // store size of 'blobToStore':
        let blobToStoreSize = blobToStore.size();
        Region.storeNat32(memoryStorage.memory_region.region, memoryAddress + offsets.internalBlobSize, Nat32.fromNat(blobToStoreSize));

        // store internalBlobAllocatedSize
        let internalBlobAllocatedSize : Nat = blobToStoreSize + Nat32.toNat(memoryStorage.replaceBufferSize);

        Region.storeNat32(
            memoryStorage.memory_region.region,
            memoryAddress + offsets.internalBlobAllocatedSize,
            Nat32.fromNat(internalBlobAllocatedSize),
        );

        // store now the actual blob 'blobToStore'
        let memoryAddressOfInternalBlob = Nat64.fromNat(GlobalFunctions.allocate(memoryStorage, Nat64.fromNat(internalBlobAllocatedSize)));
        Region.storeBlob(memoryStorage.memory_region.region, memoryAddressOfInternalBlob, blobToStore);

        // and now store the related internal-blob-address
        Region.storeNat64(memoryStorage.memory_region.region, memoryAddress + offsets.internalBlobAddress, memoryAddressOfInternalBlob);

        return memoryAddress;
    };

};
