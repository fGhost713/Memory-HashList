import Blob "mo:base/Blob";
import Nat64 "mo:base/Nat64";
import Region "mo:base/Region";
import Option "mo:base/Option";
import CommonTypes "../types/commonTypes";
import MemoryStorageTypes "../types/memoryStorage/memoryStorageTypes";
import GlobalFunctions "../helpers/globalFunctions";

module {

    public class libWrappedBlob(memoryStorageToUse : MemoryStorageTypes.MemoryStorage) {

        private let memoryStorage : MemoryStorageTypes.MemoryStorage = memoryStorageToUse;
        private let offsets = CommonTypes.Offsets_WrappedBlob;

        public func get_internal_blob_size_from_address(memoryAddress : Nat64) : Nat64 {
            Region.loadNat64(memoryStorage.memory_region.region, memoryAddress + offsets.internalBlobSize);
        };

        public func set_internal_blob_size(memoryAddress : Nat64, blobSize : Nat64) {
            Region.storeNat64(memoryStorage.memory_region.region, memoryAddress + offsets.internalBlobSize, blobSize);
        };

        public func get_internal_blob_allocated_size_from_address(memoryAddress : Nat64) : Nat64 {
            Region.loadNat64(memoryStorage.memory_region.region, memoryAddress + offsets.internalBlobAllocatedSize);
        };

        public func set_internal_blob_allocated_size(memoryAddress : Nat64, allocatedBlobSize : Nat64) {
            Region.storeNat64(memoryStorage.memory_region.region, memoryAddress + offsets.internalBlobAllocatedSize, allocatedBlobSize);
        };

        public func get_memory_address_of_internal_blob(memoryAddress : Nat64) : Nat64 {
            Region.loadNat64(memoryStorage.memory_region.region, memoryAddress + offsets.internalBlobAddress);
        };

        public func set_memory_address_of_internal_blob(memoryAddress : Nat64, internalBlobAddress : Nat64) {
            Region.storeNat64(memoryStorage.memory_region.region, memoryAddress + offsets.internalBlobAddress, internalBlobAddress);
        };

        public func update_previous_wrapped_blob_address_value(memoryAddress : Nat64, newPreviousAddress : Nat64) {
            // Address of previous item
            Region.storeNat64(memoryStorage.memory_region.region, memoryAddress + offsets.addressOfPreviousItem, newPreviousAddress);
        };

        public func update_next_wrapped_blob_address_value(memoryAddress : Nat64, newNextAddress : Nat64) {
            // Address of next item
            Region.storeNat64(memoryStorage.memory_region.region, memoryAddress + offsets.addressOfNextItem, newNextAddress);
        };

        public func get_previous_wrapped_blob_address(memoryAddress : Nat64) : (Bool, Nat64) {
            // Address of previous item
            let previousAddress = Region.loadNat64(memoryStorage.memory_region.region, memoryAddress + offsets.addressOfPreviousItem);
            if (previousAddress == memoryAddress) {
                return (false, 0);
            };
            (true, previousAddress);
        };

        public func get_next_wrapped_blob_address(memoryAddress : Nat64) : (Bool, Nat64) {
            // Address of next item
            let nextAddress = Region.loadNat64(memoryStorage.memory_region.region, memoryAddress + offsets.addressOfNextItem);
            if (nextAddress == memoryAddress) {
                return (false, 0);
            };
            (true, nextAddress);
        };

        public func get_inner_blob_from_wrapped_blob_Address(memoryAddress : Nat64) : Blob {
            let blobSize = get_internal_blob_size_from_address(memoryAddress);
            let internalBlobAddress : Nat64 = get_memory_address_of_internal_blob(memoryAddress);
            Region.loadBlob(memoryStorage.memory_region.region, internalBlobAddress, Nat64.toNat(blobSize));
        };

        // delete the wrapped blob.
        // -> returns true if it was the last wrapped-blob, otherwise false is returned.
        public func delete_wrapped_blob(wrappedBlobAddress : Nat64) : Bool {
            let previousItemResult = get_previous_wrapped_blob_address(wrappedBlobAddress);
            let nextItemResult = get_next_wrapped_blob_address(wrappedBlobAddress);

            let allocatedInnerBlobSize = get_internal_blob_allocated_size_from_address(wrappedBlobAddress);
            let innerBlobAddress = get_memory_address_of_internal_blob(wrappedBlobAddress);

            // deallocate internal blob
            GlobalFunctions.deallocate(memoryStorage, innerBlobAddress, allocatedInnerBlobSize);

            // deallocate wrapped-blob
            GlobalFunctions.deallocate(memoryStorage, wrappedBlobAddress, offsets.bytesNeeded);

            if (previousItemResult.0 == true) {
                // If we are here, then predecessor is existing

                if (nextItemResult.0 == true) {
                    // If we are here, then successor is existing
                    update_next_wrapped_blob_address_value(previousItemResult.1, nextItemResult.1);
                    update_previous_wrapped_blob_address_value(nextItemResult.1, previousItemResult.1);

                } else {
                    // set next item to itself for the predecessor item
                    update_next_wrapped_blob_address_value(previousItemResult.1, previousItemResult.1);
                };
            } else if (nextItemResult.0 == true) {
                // If we are here then the next item will be the new first item

                // set the previous item to itself, so it is marked as first item
                update_previous_wrapped_blob_address_value(nextItemResult.1, nextItemResult.1);

            } else {
                return true;
            };

            return false;

        };

        // insert wrapped-blob before 'nextWrappedBlobAddress'
        // -> returns first tuple as true when the inserted blob is now the new first element,
        //    and otherwise false is returned.
        //    The second tuple is the new wrappedBlob-memory address
        public func create_and_insert_new_wrapped_blob(nextWrappedBlobAddress : Nat64, newBlobToStore : Blob) : (Bool, Nat64) {

            let previousItemResult = get_previous_wrapped_blob_address(nextWrappedBlobAddress);
            var previousWrappedBlobAddress : ?Nat64 = null;
            if (previousItemResult.0 == true) {
                previousWrappedBlobAddress := Option.make(previousItemResult.1);
            };

            // create new wrappedBlob
            let insertedWrappedBlobAddress : Nat64 = create_new(
                newBlobToStore,
                previousWrappedBlobAddress,
                Option.make(nextWrappedBlobAddress),
            );

            if (previousItemResult.0 == true) {
                update_next_wrapped_blob_address_value(previousItemResult.1, insertedWrappedBlobAddress);
            };

            update_previous_wrapped_blob_address_value(nextWrappedBlobAddress, insertedWrappedBlobAddress);

            if (previousItemResult.0 == true) {
                return (false, insertedWrappedBlobAddress);
            };

            return (true, insertedWrappedBlobAddress);
        };

        public func update_inner_blob(wrappedBlobAddress : Nat64, newBlobToStore : Blob) {

            let newBlobSize : Nat = newBlobToStore.size();
            let newBlobSizeNat64 : Nat64 = Nat64.fromNat(newBlobSize);
            let oldBlobAddress : Nat64 = get_memory_address_of_internal_blob(wrappedBlobAddress);

            let allocatedSize : Nat64 = get_internal_blob_allocated_size_from_address(wrappedBlobAddress);
            if (newBlobSizeNat64 <= allocatedSize) {
                // we can directly overwrite the previous blob in memory

                // set the new size
                set_internal_blob_size(wrappedBlobAddress, newBlobSizeNat64);

                // overwrite old blob with new blob
                Region.storeBlob(memoryStorage.memory_region.region, oldBlobAddress, newBlobToStore);

            } else {
                // we need to delete old internal-blob memory and reallocate new memory + store the updated blob

                // deallocate the old blob
                GlobalFunctions.deallocate(memoryStorage, oldBlobAddress, allocatedSize);

                // allocate new memory space
                let allocatedSizeForUpdatedBlob = newBlobSize + Nat64.toNat(memoryStorage.replaceBufferSize);
                let newInternalBlobAddress = GlobalFunctions.allocate(memoryStorage, Nat64.fromNat(allocatedSizeForUpdatedBlob));

                // store the allocated-size
                set_internal_blob_allocated_size(wrappedBlobAddress, Nat64.fromNat(allocatedSizeForUpdatedBlob));

                // store the updated blob
                Region.storeBlob(memoryStorage.memory_region.region, Nat64.fromNat(newInternalBlobAddress), newBlobToStore);

                // store the address of the updated blob
                set_memory_address_of_internal_blob(wrappedBlobAddress, Nat64.fromNat(newInternalBlobAddress));

                // store the allocated-size-value
                set_internal_blob_allocated_size(wrappedBlobAddress, Nat64.fromNat(allocatedSizeForUpdatedBlob));

                // store the size of the updated blob
                set_internal_blob_size(wrappedBlobAddress, newBlobSizeNat64);
            };

        };

        // Create and store new wrappedBlob entry in memory.
        // -> The wrapped-Blob is written directly into memory.
        //    This means the actual blob for the type 'wrappedBlob'
        //    (defined in types/wrappedBlob/wrappedBlobTypes.mo') is not created.

        public func create_new(
            blobToStore : Blob,
            previousWrappedBlobAddress : ?Nat64,
            nextWrappedBlobAddress : ?Nat64,
        ) : Nat64 /* stored wrappedBlob address*/ {

            // allocate memory and get the memory address

            let memoryAddress = Nat64.fromNat(GlobalFunctions.allocate(memoryStorage, offsets.bytesNeeded));

            let addressOfPreviousWrappedBlob : Nat64 = Option.get(previousWrappedBlobAddress, memoryAddress);
            let addressOfNextWrappedBlob : Nat64 = Option.get(nextWrappedBlobAddress, memoryAddress);

            // Store the wrappedBlob info direct into memory.
            // (This is faster than create and save instance of 'wrappedBlob'-type into memory)

            // Address of next item
            Region.storeNat64(memoryStorage.memory_region.region, memoryAddress + offsets.addressOfNextItem, addressOfNextWrappedBlob);

            // Address of previous item
            Region.storeNat64(memoryStorage.memory_region.region, memoryAddress + offsets.addressOfPreviousItem, addressOfPreviousWrappedBlob);

            // store size of 'blobToStore':
            let blobToStoreSize = blobToStore.size();
            Region.storeNat64(memoryStorage.memory_region.region, memoryAddress + offsets.internalBlobSize, Nat64.fromNat(blobToStoreSize));

            // store now the actual blob 'blobToStore'
            let internalBlobAllocatedSize = blobToStoreSize + Nat64.toNat(memoryStorage.replaceBufferSize);

            Region.storeNat64(
                memoryStorage.memory_region.region,
                memoryAddress + offsets.internalBlobAllocatedSize,
                Nat64.fromNat(internalBlobAllocatedSize),
            );

            let memoryAddressOfInternalBlob = Nat64.fromNat(GlobalFunctions.allocate(memoryStorage, Nat64.fromNat(internalBlobAllocatedSize)));
            Region.storeBlob(memoryStorage.memory_region.region, memoryAddressOfInternalBlob, blobToStore);

            // and now store the related internal-blob-address
            Region.storeNat64(memoryStorage.memory_region.region, memoryAddress + offsets.internalBlobAddress, memoryAddressOfInternalBlob);

            return memoryAddress;
        };
    };
};
