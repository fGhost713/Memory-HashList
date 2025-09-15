import Iter "mo:base/Iter";
import Option "mo:base/Option";
import Array "mo:base/Array";
import Nat "mo:base/Nat";
import Result "mo:base/Result";
import Nat64 "mo:base/Nat64";
import CommonTypes "../types/commonTypes";
import Vector "mo:vector";
import LibWrappedBlob "libWrappedBlob";

module libIndex = {

    private type MemoryStorage = CommonTypes.MemoryStorage;

    public func is_free_vector_available(memoryStorage : MemoryStorage) : Bool {
        Vector.size(memoryStorage.indizesPerKey_free) > 0;
    };

    // Clear the inner-vector index and mark as free
    public func empty_inner_vector(memoryStorage : MemoryStorage, outerIndex : Nat) {

        if (Vector.size(memoryStorage.indizesPerKey) > outerIndex) {
            let innerVector : Vector.Vector<Nat64> = Vector.get(memoryStorage.indizesPerKey, outerIndex);
            Vector.clear<Nat64>(innerVector);

            // make sure every index is only one time inserted.
            // (For example if this method 'empty_inner_vector' is called twice we would else have two times the same value in vector)
            if (Vector.contains(memoryStorage.indizesPerKey_free, outerIndex, Nat.equal) == false) {
                Vector.add(memoryStorage.indizesPerKey_free, outerIndex);
            };
        };
    };

    // Creating and returning new outer-index
    public func create_and_get_new_outer_vector_index(memoryStorage : MemoryStorage) : Nat {
        if (is_free_vector_available(memoryStorage) == true) {

            let outerIndexOrNull = Vector.removeLast(memoryStorage.indizesPerKey_free);
            switch (outerIndexOrNull) {
                case (?outerIndex) {
                    let innerVector : Vector.Vector<Nat64> = Vector.get(memoryStorage.indizesPerKey, outerIndex);
                    Vector.clear<Nat64>(innerVector);
                    return outerIndex;
                };
                case (_) {
                    return create_completely_new_vector_internal(memoryStorage);
                };
            };

        } else {
            // add completely new vector
            return create_completely_new_vector_internal(memoryStorage);
        };
    };

    // Adding wrapped-blob address as value into the vector
    public func append_wrapped_blob_memory_address(memoryStorage : MemoryStorage, outerIndex : Nat, wrappedBlobAddress : Nat64) {
        let innerVector : Vector.Vector<Nat64> = Vector.get(memoryStorage.indizesPerKey, outerIndex);
        Vector.add<Nat64>(innerVector, wrappedBlobAddress);
    };

    // The performance is slow. (O(n))
    // remove many elements from 'startInde' to 'lastIndex'
    public func remove_at_range(memoryStorage : MemoryStorage, outerIndex : Nat, startIndex : Nat, lastIndex : Nat, deleteAlsoWrappedBlob : Bool) {

        let innerVectorOrNull = get_inner_vector(memoryStorage, outerIndex);
        switch (innerVectorOrNull) {
            case (?innerVector) {
                let vectorSize = Vector.size(innerVector);
                if (vectorSize == 0 or lastIndex < startIndex or startIndex >= vectorSize) {
                    return;
                };

                let lastIndexToUse = Nat.min(lastIndex, vectorSize -1);

                if (vectorSize > startIndex) {
                    let numbersToRemove : Nat = (lastIndexToUse - startIndex) + 1;

                    if (deleteAlsoWrappedBlob == true) {

                        for (i in Iter.range(startIndex, lastIndex)) {
                            let wrappedBlobAddressOrNull : ?Nat64 = Vector.getOpt(innerVector, i);
                            switch (wrappedBlobAddressOrNull) {
                                case (?wrappedBlobAddress) {
                                    ignore LibWrappedBlob.delete_wrapped_blob(memoryStorage, wrappedBlobAddress);
                                };
                                case (_) {

                                };
                            };
                        };
                    };

                    if (vectorSize == 1 and startIndex == 0) {
                        ignore Vector.removeLast(innerVector);
                        return;
                    };

                    for (index in Iter.range(startIndex + numbersToRemove, vectorSize -1)) {
                        let vecVal : Nat64 = Vector.get(innerVector, index);
                        let prevIndex : Nat = index - numbersToRemove;
                        Vector.put(innerVector, prevIndex, vecVal);
                    };
                    for (index in Iter.range(1, numbersToRemove)) {
                        ignore Vector.removeLast(innerVector);
                    };

                } else {

                };
            };
            case (_) {

                return;
            };
        };

    };

    // The performance is slow. (O(n))
    // Removed the element at index
    public func remove_at_index(memoryStorage : MemoryStorage, outerIndex : Nat, innerIndex : Nat, deleteAlsoWrappedBlob : Bool) {

        return remove_at_range(memoryStorage, outerIndex, innerIndex, innerIndex, deleteAlsoWrappedBlob);
    };

    // The last Element is removed
    public func remove_last_element(memoryStorage : MemoryStorage, outerIndex : Nat) : ?Nat64 {
        let innerVectorOrNull = get_inner_vector(memoryStorage, outerIndex);
        switch (innerVectorOrNull) {
            case (?innerVector) {
                Vector.removeLast(innerVector);
            };
            case (_) {
                return null;
            };
        };

    };

    // Add many blobs (inserted into wrapped-blob) into memory
    public func create_many_addresses_and_insert_at_index(memoryStorage : MemoryStorage, outerIndex : Nat, innerIndex : Nat, blobs : [Blob]) : Result.Result<Text, Text> {
        if (Array.size(blobs) == 0) {
            return #err("no blobs to add.");
        };

        let innerVectorOrNull = get_inner_vector(memoryStorage, outerIndex);
        switch (innerVectorOrNull) {
            case (?innerVector) {
                let vectorSize = Vector.size(innerVector);

                if (vectorSize == 0) {
                    if (innerIndex == 0) {
                        for (blob : Blob in Iter.fromArray(blobs)) {
                            let address : Nat64 = LibWrappedBlob.create_new(memoryStorage, blob);
                            Vector.add<Nat64>(innerVector, address);
                        };
                        return #ok("");
                    };
                    return #err("Index not found.");
                };

                if (vectorSize == 1) {
                    if (innerIndex == 0) {
                        let tempValue = Vector.get(innerVector, 0);
                        Vector.clear<Nat64>(innerVector);

                        for (blob : Blob in Iter.fromArray(blobs)) {
                            let address : Nat64 = LibWrappedBlob.create_new(memoryStorage, blob);
                            Vector.add<Nat64>(innerVector, address);
                        };
                        Vector.add(innerVector, tempValue);
                        return #ok("");
                    };
                    return #err("Index not found.");
                };

                if (vectorSize > innerIndex) {

                    // add dummy elements (will be overwritten later)
                    for (blob : Blob in Iter.fromArray(blobs)) {
                        Vector.add<Nat64>(innerVector, 0);
                    };

                    // number of items to insert
                    let countNewItems : Nat = Array.size(blobs);

                    let vecLength = Vector.size(innerVector);

                    // set currIndex to last index
                    var currIndex : Nat = vecLength - countNewItems;

                    for (index in Iter.range(innerIndex, vectorSize - 1)) {
                        currIndex := currIndex - 1;
                        let sourceItem : Nat64 = Vector.get(innerVector, currIndex);
                        Vector.put(innerVector, currIndex + countNewItems, sourceItem);
                    };

                    currIndex := innerIndex;
                    for (blob : Blob in Iter.fromArray(blobs)) {
                        let address : Nat64 = LibWrappedBlob.create_new(memoryStorage, blob);
                        Vector.put<Nat64>(innerVector, currIndex, address);
                        currIndex := currIndex + 1;
                    };
                    return #ok("");
                } else {
                    return #err("Index not found.");
                };
            };
            case (_) {
                return #err("Index not found.");
            };
        };

    };

    // The performance is slow. (O(n))
    public func create_address_and_insert_at_index(memoryStorage : MemoryStorage, outerIndex : Nat, innerIndex : Nat, blob : Blob) : Result.Result<Text, Text> {
        return create_many_addresses_and_insert_at_index(memoryStorage, outerIndex, innerIndex, [blob]);
    };

    // Returns the address of wrapped-blob for the last inner-index (== last element)
    public func get_address_of_last_stored_wrapped_blob(memoryStorage : MemoryStorage, outerIndex : Nat) : ?Nat64 {

        let innerVector_or_null : ?Vector.Vector<Nat64> = get_inner_vector(memoryStorage, outerIndex);
        switch (innerVector_or_null) {
            case (?innerVector) {

                let innerVectorSize : Nat = Vector.size(innerVector);

                if (innerVectorSize == 0) {
                    return null;
                };
                // return the last element
                return get_last_element(memoryStorage, innerVector);

            };
            case (_) {
                return null;
            };
        };

    };

    // returns the related wrapped-blob address.
    public func get_wrapped_blob_Address(memoryStorage : MemoryStorage, outerIndex : Nat, innerIndex : Nat) : ?Nat64 {
        let innerVector_or_null : ?Vector.Vector<Nat64> = get_inner_vector(memoryStorage, outerIndex);
        switch (innerVector_or_null) {
            case (?innerVector) {

                let result : ?Nat64 = Vector.getOpt(innerVector, innerIndex);
                return result;

            };
            case (_) {
                return null;
            };
        };
    };

    // return last index or null if empty
    public func get_last_index(memoryStorage : MemoryStorage, outerIndex : Nat) : ?Nat {

        let innerVector_or_null : ?Vector.Vector<Nat64> = get_inner_vector(memoryStorage, outerIndex);
        switch (innerVector_or_null) {
            case (?innerVector) {

                var result : Nat = Vector.size(innerVector);
                if (result == 0) {
                    return null;
                };
                result := result -1;
                return ?result;
            };
            case (_) {
                return null;
            };
        };

    };

    private func get_inner_vector(memoryStorage : MemoryStorage, outerIndex : Nat) : ?Vector.Vector<Nat64> {
        if (Vector.size(memoryStorage.indizesPerKey) <= outerIndex) {
            return null;
        };

        let innerVector : Vector.Vector<Nat64> = Vector.get(memoryStorage.indizesPerKey, outerIndex);
        return Option.make(innerVector);
    };

    private func create_completely_new_vector_internal(memoryStorage : MemoryStorage) : Nat {
        Vector.add(memoryStorage.indizesPerKey, Vector.new<Nat64>());
        return (Vector.size(memoryStorage.indizesPerKey) - 1);
    };

    private func get_last_element(memoryStorage : MemoryStorage, vec : Vector.Vector<Nat64>) : ?Nat64 {

        let size : Nat = Vector.size(vec);
        if (size == 0) {
            return null;
        };

        Vector.getOpt<Nat64>(vec, size -1);
    };

};
