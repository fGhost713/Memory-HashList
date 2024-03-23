import Iter "mo:base/Iter";
import Option "mo:base/Option";
import GlobalFunctions "../helpers/globalFunctions";
import CommonTypes "../types/commonTypes";
import Vector "mo:vector";

module {

    private type MemoryStorage = CommonTypes.MemoryStorage;

    public class libIndex(memoryStorageToUse : MemoryStorage) {

        private let memoryStorage : MemoryStorage = memoryStorageToUse;

        public func is_free_vector_available() : Bool {
            Vector.size(memoryStorage.indizesPerKey_free) > 0;
        };

        public func empty_inner_vector(outerIndex : Nat) {
            if (Vector.size(memoryStorage.indizesPerKey) > outerIndex) {
                let innerVector : Vector.Vector<Nat64> = Vector.get(memoryStorage.indizesPerKey, outerIndex);
                Vector.clear<Nat64>(innerVector);
                Vector.add(memoryStorage.indizesPerKey_free, outerIndex);
            };
        };

        public func add_outer_vector() : Nat {
            if (is_free_vector_available() == true) {
                let freeIndexOrNull : ?Nat = Vector.removeLast<Nat>(memoryStorage.indizesPerKey_free);
                switch (freeIndexOrNull) {
                    case (?freeIndex) {
                        empty_inner_vector(freeIndex);
                        return freeIndex;
                    };
                    case (_) {
                        // We need to create completely new vector
                        return create_completely_new_vector_internal();
                    };
                };

            } else {
                // add completely new vector
                return create_completely_new_vector_internal();
            };
        };

        public func append_wrapped_blob_memory_address(outerIndex : Nat, wrappedBlobAddress : Nat64) {
            let innerVector : Vector.Vector<Nat64> = Vector.get(memoryStorage.indizesPerKey, outerIndex);
            Vector.add<Nat64>(innerVector, wrappedBlobAddress);
        };

        // The performance is slow. (O(n))
        public func remove_at_index(outerIndex : Nat, innerIndex : Nat) {

            let innerVectorOrNull = get_inner_vector(outerIndex);
            switch (innerVectorOrNull) {
                case (?innerVector) {
                    let vectorSize = Vector.size(innerVector);
                    if (vectorSize == 0) {
                        return;
                    };

                    if (vectorSize > innerIndex) {
                        if (vectorSize == 1 or innerIndex == vectorSize + 1) {
                            ignore Vector.removeLast(innerVector);
                            return;
                        };

                        for (index in Iter.range(innerIndex +1, vectorSize -1)) {
                            let vecVal : Nat64 = Vector.get(innerVector, index);
                            let prevIndex : Nat = index -1;
                            Vector.put(innerVector, prevIndex, vecVal);
                        };
                        ignore Vector.removeLast(innerVector);
                    };

                };
                case (_) {
                    return;
                };
            };
        };

        private func get_last_element(vec : Vector.Vector<Nat64>) : ?Nat64 {

            let size : Nat = Vector.size(vec);
            if (size == 0) {
                return null;
            };

            Vector.getOpt<Nat64>(vec, size -1);
        };

        public func remove_last_element(outerIndex : Nat) : ?Nat64 {
            let innerVectorOrNull = get_inner_vector(outerIndex);
            switch (innerVectorOrNull) {
                case (?innerVector) {
                    Vector.removeLast(innerVector);
                };
                case (_) {
                    return null;
                };
            };

        };

        // The performance is slow. (O(n))
        public func insert_at_index(outerIndex : Nat, innerIndex : Nat, wrappedBlobAddress : Nat64) {

            let innerVectorOrNull = get_inner_vector(outerIndex);
            switch (innerVectorOrNull) {
                case (?innerVector) {
                    let vectorSize = Vector.size(innerVector);

                    if (vectorSize == 0) {
                        if (innerIndex == 0) {
                            append_wrapped_blob_memory_address(outerIndex, wrappedBlobAddress);
                        };
                        return;
                    };

                    if (vectorSize == 1) {
                        if (innerIndex == 0) {
                            let tempValue = Vector.get(innerVector, 0);
                            Vector.put(innerVector, 0, wrappedBlobAddress);
                            Vector.add(innerVector, tempValue);
                        };
                        return;
                    };

                    if (vectorSize > innerIndex) {

                        let lastElementOrNull = get_last_element(innerVector);
                        switch (lastElementOrNull) {
                            case (?foundLastElement) {
                                // add dummy element (will be overwritten later)
                                Vector.add(innerVector, foundLastElement);
                            };
                            case (_) {
                                append_wrapped_blob_memory_address(outerIndex, wrappedBlobAddress);
                                return;
                            };
                        };

                        var currIndex : Nat = vectorSize;

                        for (index in Iter.range(innerIndex, vectorSize -1)) {
                            currIndex := currIndex -1;
                            let vecVal = Vector.get(innerVector, currIndex);
                            let nextIndex : Nat = currIndex +1;
                            Vector.put(innerVector, nextIndex, vecVal);
                        };
                        Vector.put(innerVector, innerIndex, wrappedBlobAddress);
                    };

                };
                case (_) {
                    return;
                };
            };
        };

        public func get_address_of_last_stored_wrapped_blob(outerIndex : Nat) : ?Nat64 {

            let innerVector_or_null : ?Vector.Vector<Nat64> = get_inner_vector(outerIndex);
            switch (innerVector_or_null) {
                case (?innerVector) {

                    let innerVectorSize : Nat = Vector.size(innerVector);

                    if (innerVectorSize == 0) {
                        return null;
                    };
                    // return the last element
                    return get_last_element(innerVector);

                };
                case (_) {
                    return null;
                };
            };

        };

        public func get_wrapped_blob_Address(outerIndex : Nat, innerIndex : Nat) : ?Nat64 {
            let innerVector_or_null : ?Vector.Vector<Nat64> = get_inner_vector(outerIndex);
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
        public func get_last_index(outerIndex : Nat) : ?Nat {

            let innerVector_or_null : ?Vector.Vector<Nat64> = get_inner_vector(outerIndex);
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

        private func get_inner_vector(outerIndex : Nat) : ?Vector.Vector<Nat64> {
            if (Vector.size(memoryStorage.indizesPerKey) <= outerIndex) {
                return null;
            };

            let innerVector : Vector.Vector<Nat64> = Vector.get(memoryStorage.indizesPerKey, outerIndex);
            return Option.make(innerVector);
        };

        private func create_completely_new_vector_internal() : Nat {
            Vector.add(memoryStorage.indizesPerKey, Vector.new<Nat64>());
            return (Vector.size(memoryStorage.indizesPerKey) - 1);
        };

    };
};
