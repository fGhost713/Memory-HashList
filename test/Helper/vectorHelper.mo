import Blob "mo:base/Blob";
import StableTrieMap "mo:StableTrieMap";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Region "mo:base/Region";
import Iter "mo:base/Iter";
import List "mo:base/List";
import Binary "../../src/helpers/binary";
import Itertools "mo:itertools/Iter";
import Option "mo:base/Option";
import Debug "mo:base/Debug";
import Nat "mo:base/Nat";
import Result "mo:base/Result";
import Array "mo:base/Array";
import { MemoryRegion } "mo:memory-region";
import GlobalFunctions "../../src/helpers/globalFunctions";
import CommonTypes "../../src/types/commonTypes";
import Vector "mo:vector";

module {

    // Vector helper class used inside the tests.
    // This class will hold the reference results for the test "doing many different operations Tests"
    public class vectorHelper() {

        public let innerVector : Vector.Vector<Blob> = Vector.new();

        public func empty_vector() {
            Vector.clear<Blob>(innerVector);
        };

        public func add(item : Blob) {
            Vector.add<Blob>(innerVector, item);
        };

        public func remove_at_range(startIndex : Nat, lastIndex : Nat) {

            let vectorSize = Vector.size(innerVector);
            if (vectorSize == 0 or lastIndex < startIndex or startIndex >= vectorSize) {
                return;
            };

            let lastIndexToUse = Nat.min(lastIndex, vectorSize -1);

            if (vectorSize > startIndex) {
                let numbersToRemove : Nat = (lastIndexToUse - startIndex) + 1;

                if (vectorSize == 1 and startIndex == 0) {
                    ignore Vector.removeLast(innerVector);
                    return;
                };

                for (index in Iter.range(startIndex + numbersToRemove, vectorSize -1)) {
                    let vecVal : Blob = Vector.get(innerVector, index);
                    let prevIndex : Nat = index - numbersToRemove;
                    Vector.put(innerVector, prevIndex, vecVal);
                };
                for (index in Iter.range(1, numbersToRemove)) {
                    ignore Vector.removeLast(innerVector);
                };
            };
        };

        // The performance is slow. (O(n))
        public func remove_at_index(innerIndex : Nat) {

            let vectorSize = Vector.size(innerVector);
            if (vectorSize == 0) {
                return;
            };

            if (vectorSize > innerIndex) {
                if (vectorSize == 1) {
                    ignore Vector.removeLast(innerVector);
                    return;
                };

                for (index in Iter.range(innerIndex +1, vectorSize -1)) {
                    let vecVal = Vector.get(innerVector, index);
                    let prevIndex : Nat = index -1;
                    Vector.put(innerVector, prevIndex, vecVal);
                };
                ignore Vector.removeLast(innerVector);
            };
        };

        private func get_last_element() : ?Blob {

            let size : Nat = Vector.size(innerVector);
            if (size == 0) {
                return null;
            };

            Vector.getOpt<Blob>(innerVector, size -1);
        };

        public func remove_last_element() {
            ignore Vector.removeLast<Blob>(innerVector);
        };

        public func update_at_index(index : Nat, item : Blob) {
            let vectorSize = Vector.size(innerVector);
            if (vectorSize > index) {
                Vector.put<Blob>(innerVector, index, item);
            };
        };

        public func insert_many_at_index(innerIndex : Nat, values : [Blob]) {
            if (Array.size(values) == 0) {
                return;
            };

            let vectorSize = Vector.size(innerVector);

            if (vectorSize == 0) {
                if (innerIndex == 0) {
                    for (address : Blob in Iter.fromArray(values)) {
                        Vector.add<Blob>(innerVector, address);
                    };
                };
                return;
            };

            if (vectorSize == 1) {
                if (innerIndex == 0) {
                    let tempValue = Vector.get(innerVector, 0);
                    Vector.clear<Blob>(innerVector);

                    for (address : Blob in Iter.fromArray(values)) {
                        Vector.add<Blob>(innerVector, address);
                    };
                    Vector.add(innerVector, tempValue);
                };
                return;
            };

            if (vectorSize > innerIndex) {

                // add dummy elements (will be overwritten later)
                for (address : Blob in Iter.fromArray(values)) {
                    Vector.add<Blob>(innerVector, address);
                };

                // number of items to insert
                let countNewItems : Nat = Array.size(values);

                let vecLength = Vector.size(innerVector);

                // set currIndex to last index
                var currIndex : Nat = vecLength - countNewItems;

                for (index in Iter.range(innerIndex, vectorSize - 1)) {
                    currIndex := currIndex - 1;
                    Vector.put(innerVector, currIndex + countNewItems, Vector.get(innerVector, currIndex));
                };

                currIndex := innerIndex;
                for (address : Blob in Iter.fromArray(values)) {
                    Vector.put<Blob>(innerVector, currIndex, address);
                    currIndex := currIndex + 1;
                };
            };

        };

        // The performance is slow. (O(n))
        public func insert_at_index(innerIndex : Nat, item : Blob) {

            let vectorSize = Vector.size(innerVector);

            if (vectorSize == 0) {
                if (innerIndex == 0) {
                    add(item);
                };
                return;
            };

            if (vectorSize == 1) {
                if (innerIndex == 0) {
                    let tempValue = Vector.get(innerVector, 0);
                    Vector.put(innerVector, 0, item);
                    Vector.add(innerVector, tempValue);
                };
                return;
            };

            if (vectorSize > innerIndex) {

                let lastElementOrNull = get_last_element();
                switch (lastElementOrNull) {
                    case (?foundLastElement) {
                        Vector.add(innerVector, foundLastElement);
                    };
                    case (_) {
                        add(item);
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
                Vector.put(innerVector, innerIndex, item);
            };

        };

        public func get_last_value() : ?Blob {

            let innerVectorSize : Nat = Vector.size(innerVector);

            if (innerVectorSize == 0) {
                return null;
            };
            // return the last element
            return get_last_element();
        };

        public func get_at_index(innerIndex : Nat) : ?Blob {
            Vector.getOpt(innerVector, innerIndex);
        };

        public func get_at_range(firstIndex : Nat, lastIndex : Nat) : [?Blob] {
          
            let lastIndexOrNull : ?Nat = get_last_index();
            switch (lastIndexOrNull) {
                case (?foundLastIndex) {
                    if (firstIndex > foundLastIndex or firstIndex > lastIndex) {
                        return [];
                    };
                    let lastIndexToUse : Nat = Nat.min(lastIndex, foundLastIndex);

                    let vector : Vector.Vector<?Blob> = Vector.new();
                    for (index in Iter.range(firstIndex, lastIndexToUse)) {
                        let blobOrNull = get_at_index(index);
                        Vector.add<?Blob>(vector, blobOrNull);
                    };
                    return Vector.toArray(vector);

                };
                case (_) {
                    return [];
                };
            };

        };

        // return last index or null if empty
        public func get_last_index() : ?Nat {

            var result : Nat = Vector.size(innerVector);
            if (result == 0) {
                return null;
            };
            result := result -1;
            return ?result;

        };

        public func size() : Nat {
            Vector.size(innerVector);
        };

    };
};
