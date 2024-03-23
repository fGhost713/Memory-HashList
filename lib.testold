// @testmode wasi
import lib "../src/lib";
import Blob "mo:base/Blob";
import Text "mo:base/Text";
import Option "mo:base/Option";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";
import Nat64 "mo:base/Nat64";

import { test; suite } "mo:test";

    type OwnType = {
        myNumber : Nat;
        myText : Text;
    };
    let ownType1 : OwnType = {
        myNumber : Nat = 2345;
        myText : Text = "Hello World";
    };
    let ownType2 : OwnType = {
        myNumber : Nat = 79;
        myText : Text = "";
    };
    let ownType3 : OwnType = {
        myNumber : Nat = 0;
        myText : Text = "My test text";
    };

    let ownType1Blob : Blob = to_candid (ownType1);
    let ownType2Blob : Blob = to_candid (ownType2);
    let ownType3Blob : Blob = to_candid (ownType3);

    func ownType_getDefaultType() : OwnType {
        let result : OwnType = {
            myNumber = 0;
            myText = "";
        };
    };

    func ownType_blobs_array_are_equal_check(items1 : [Blob], items2 : [Blob]) {

        assert (items1.size() == items2.size());

        for (index in Iter.range(0, items1.size() -1)) {
            ownType_blobs_are_equal_check(items1[index], items2[index]);
        };
    };

    func ownType_blobs_are_equal_check(item1_blob : Blob, item2_blob : Blob) {

        let item1OrNull : ?OwnType = from_candid (item1_blob);
        let item2OrNull : ?OwnType = from_candid (item2_blob);

        let defType = ownType_getDefaultType();

        let item1 = Option.get(item1OrNull, defType);
        let item2 = Option.get(item2OrNull, { defType with MyNumber = 7 });

        assert (item1 == item2);
    };

    func ownType_blobs_are_not_equal_check(item1_blob : Blob, item2_blob : Blob) {

        let item1OrNull : ?OwnType = from_candid (item1_blob);
        let item2OrNull : ?OwnType = from_candid (item2_blob);

        let defType = ownType_getDefaultType();

        let item1 = Option.get(item1OrNull, defType);
        let item2 = Option.get(item2OrNull, { defType with MyNumber = 7 });

        assert (item1 != item2);
    };

    func ownType_blobs_are_not_null_and_equal_check(item1_blob : ?Blob, item2_blob : ?Blob) {

        assert (Option.isNull(item1_blob) == false and Option.isNull(item2_blob) == false);

        let defType = ownType_getDefaultType();
        let item1OrNull : ?OwnType = from_candid (Option.get(item1_blob, to_candid (defType)));
        let item2OrNull : ?OwnType = from_candid (Option.get(item2_blob, to_candid ({ defType with MyNumber = 3 })));

        let item1 = Option.get(item1OrNull, defType);
        let item2 = Option.get(item2OrNull, { defType with MyNumber = 7 });

        assert (item1 == item2);
    };

    func ownType_blobs_are_not_null_and_not_equal_check(item1_blob : ?Blob, item2_blob : ?Blob) {

        assert (Option.isNull(item1_blob) == false and Option.isNull(item2_blob) == false);

        let defType = ownType_getDefaultType();
        let item1OrNull : ?OwnType = from_candid (Option.get(item1_blob, to_candid (defType)));
        let item2OrNull : ?OwnType = from_candid (Option.get(item2_blob, to_candid ({ defType with MyNumber = 3 })));

        let item1 = Option.get(item1OrNull, defType);
        let item2 = Option.get(item2OrNull, { defType with MyNumber = 7 });

        assert (item1 != item2);
    };

    suite(
        "HashList tests",
        func() {
            test(
                "Single blob: 'put' and 'get' test",
                func() {

                    let mem = lib.MemoryHashList;

                    let memoryItem = lib.get_new_memory_storage();

                    let key1 : Blob = lib.Blobify.Text.to_blob("key1");
                    let key2 : Blob = lib.Blobify.Text.to_blob("key2");

                    mem.put(key1, memoryItem, ownType1Blob);

                    mem.put(key2, memoryItem, ownType3Blob);
                    mem.put(key2, memoryItem, ownType2Blob);
                    mem.put(key2, memoryItem, ownType1Blob);

                    var result1 = mem.get(key1, memoryItem);
                    var result2 = mem.get(key2, memoryItem);

                    ownType_blobs_are_not_null_and_equal_check(result1, result2);

                    mem.put(key2, memoryItem, ownType2Blob);
                    result2 := mem.get(key2, memoryItem);

                    ownType_blobs_are_not_null_and_not_equal_check(result1, result2);
                },

            );
            test(
                "Single blob: 'delete' test",
                func() {

                    let mem = lib.MemoryHashList;

                    let memoryItem = lib.get_new_memory_storage();

                    let key1 : Blob = lib.Blobify.Text.to_blob("key1");
                    let key2 : Blob = lib.Blobify.Text.to_blob("key2");

                    mem.put(key1, memoryItem, ownType1Blob);

                    mem.put(key2, memoryItem, ownType3Blob);
                    mem.put(key2, memoryItem, ownType2Blob);

                    mem.delete(key2, memoryItem);

                    var result1 = mem.get(key1, memoryItem);
                    var result2 = mem.get(key2, memoryItem);

                    assert (Option.isNull(result1) == false);
                    assert (Option.isNull(result2) == true);

                    mem.put(key2, memoryItem, ownType3Blob);
                    result2 := mem.get(key2, memoryItem);

                    ownType_blobs_are_not_null_and_not_equal_check(result1, result2);
                },

            );
            test(
                "Multi blob: 'get_all' and 'get_all_memory_addresses' test",
                func() {

                    let mem = lib.MemoryMultiHashList;

                    let memoryItem = lib.get_new_memory_storage();

                    let key1 : Blob = lib.Blobify.Text.to_blob("key1");
                    let key2 : Blob = lib.Blobify.Text.to_blob("key2");

                    let appendResult1 = mem.append(key1, memoryItem, ownType1Blob);

                    let appendResult2 = mem.append(key2, memoryItem, ownType3Blob);
                    let appendResult3 = mem.append(key2, memoryItem, ownType2Blob);
                    let appendResult4 = mem.append(key2, memoryItem, ownType1Blob);

                    var result1 : [Blob] = mem.get_all(key1, memoryItem);
                    var result2 : [Blob] = mem.get_all(key2, memoryItem);

                    ownType_blobs_are_equal_check(result1[0], result2[2]);

                    ownType_blobs_are_equal_check(ownType3Blob, result2[0]);
                    ownType_blobs_are_equal_check(ownType2Blob, result2[1]);
                    ownType_blobs_are_equal_check(ownType1Blob, result2[2]);

                    let all_adresses = mem.get_all_memory_addresses(key2, memoryItem);

                    let lastItem = all_adresses[2];
                    let elementByAddress = mem.get_by_memory_address(key2, memoryItem, lastItem);

                    ownType_blobs_are_not_null_and_equal_check(elementByAddress, Option.make(ownType1Blob));

                },
            );
            test(
                "Multi blob: 'get_all_with_adresses' and 'get_by_memory_address' test",
                func() {

                    let mem = lib.MemoryMultiHashList;

                    let memoryItem = lib.get_new_memory_storage();

                    let key1 : Blob = lib.Blobify.Text.to_blob("key1");
                    let key2 : Blob = lib.Blobify.Text.to_blob("key2");

                    let appendResult1 = mem.append(key1, memoryItem, ownType3Blob);
                    let appendResult2 = mem.append(key1, memoryItem, ownType2Blob);
                    let appendResult3 = mem.append(key1, memoryItem, ownType1Blob);

                    var result1 : [(Blob, Nat64)] = mem.get_all_with_adresses(key1, memoryItem);

                    assert (appendResult1.1 == result1[0].1);
                    assert (appendResult2.1 == result1[1].1);
                    assert (appendResult3.1 == result1[2].1);

                    let blobByAddress1 = mem.get_by_memory_address(key1, memoryItem, result1[0].1);
                    let blobByAddress2 = mem.get_by_memory_address(key1, memoryItem, result1[1].1);
                    let blobByAddress3 = mem.get_by_memory_address(key1, memoryItem, result1[2].1);

                    ownType_blobs_are_not_null_and_equal_check(Option.make(ownType3Blob), blobByAddress1);
                    ownType_blobs_are_not_null_and_equal_check(Option.make(ownType2Blob), blobByAddress2);
                    ownType_blobs_are_not_null_and_equal_check(Option.make(ownType1Blob), blobByAddress3);

                    ownType_blobs_are_not_null_and_equal_check(Option.make(result1[0].0), blobByAddress1);
                    ownType_blobs_are_not_null_and_equal_check(Option.make(result1[1].0), blobByAddress2);
                    ownType_blobs_are_not_null_and_equal_check(Option.make(result1[2].0), blobByAddress3);

                },
            );
            test(
                "Multi blob: 'get_by_index' test",
                func() {

                    let mem = lib.MemoryMultiHashList;

                    let memoryItem = lib.get_new_memory_storage();

                    let key1 : Blob = lib.Blobify.Text.to_blob("key1");
                    let key2 : Blob = lib.Blobify.Text.to_blob("key2");

                    let appendResult1 = mem.append(key1, memoryItem, ownType3Blob);
                    let appendResult2 = mem.append(key1, memoryItem, ownType2Blob);
                    let appendResult3 = mem.append(key1, memoryItem, ownType1Blob);

                    ownType_blobs_are_not_null_and_equal_check(Option.make(ownType3Blob), mem.get_by_index(key1, memoryItem, 0));
                    ownType_blobs_are_not_null_and_equal_check(Option.make(ownType2Blob), mem.get_by_index(key1, memoryItem, 1));
                    ownType_blobs_are_not_null_and_equal_check(Option.make(ownType1Blob), mem.get_by_index(key1, memoryItem, 2));

                    assert (mem.get_by_index(key1, memoryItem, 3) == null);
                },
            );

            test(
                "Multi blob: 'get_by_index_and_count' test",
                func() {

                    let mem = lib.MemoryMultiHashList;

                    let memoryItem = lib.get_new_memory_storage();

                    let key1 : Blob = lib.Blobify.Text.to_blob("key1");
                    let key2 : Blob = lib.Blobify.Text.to_blob("key2");

                    ignore mem.append(key1, memoryItem, ownType3Blob);
                    ignore mem.append(key1, memoryItem, ownType2Blob);
                    ignore mem.append(key1, memoryItem, ownType1Blob);
                    ignore mem.append(key1, memoryItem, ownType2Blob);
                    ignore mem.append(key1, memoryItem, ownType1Blob);

                    var result = mem.get_by_index_and_count(key1, memoryItem, 0, 3);
                    ownType_blobs_array_are_equal_check(result, [ownType3Blob, ownType2Blob, ownType1Blob]);

                    result := mem.get_by_index_and_count(key1, memoryItem, 0, 300);
                    ownType_blobs_array_are_equal_check(result, [ownType3Blob, ownType2Blob, ownType1Blob, ownType2Blob, ownType1Blob]);

                    result := mem.get_by_index_and_count(key1, memoryItem, 2, 2);
                    ownType_blobs_array_are_equal_check(result, [ownType1Blob, ownType2Blob]);

                    result := mem.get_by_index_and_count(key1, memoryItem, 2, 3);
                    ownType_blobs_array_are_equal_check(result, [ownType1Blob, ownType2Blob, ownType1Blob]);

                    result := mem.get_by_index_and_count(key2, memoryItem, 2, 3);
                    assert (result == []);

                },
            );

            test(
                "Multi blob: 'delete' test",
                func() {

                    let mem = lib.MemoryMultiHashList;

                    let memoryItem = lib.get_new_memory_storage();

                    let key1 : Blob = lib.Blobify.Text.to_blob("key1");
                    let key2 : Blob = lib.Blobify.Text.to_blob("key2");

                    let appendResult2 = mem.append(key1, memoryItem, ownType3Blob);
                    let appendResult3 = mem.append(key1, memoryItem, ownType2Blob);
                    let appendResult4 = mem.append(key1, memoryItem, ownType1Blob);
                    let appendResult5 = mem.append(key1, memoryItem, ownType3Blob);
                    let appendResult6 = mem.append(key1, memoryItem, ownType2Blob);

                    let all_adresses = mem.get_all_memory_addresses(key1, memoryItem);
                    let deleteResult1 = mem.delete(key1, memoryItem, all_adresses[1]);

                    assert (deleteResult1 == #ok(ownType2Blob));

                    let deleteResult2 = mem.delete(key2, memoryItem, 2332323);
                    assert (deleteResult2 == #err("The key not exist"));

                    let deleteResult3 = mem.delete(key1, memoryItem, 2332323);
                    assert (deleteResult3 == #err("No item exist at this address for the provided key"));

                    let allValues = mem.get_all(key1, memoryItem);
                    assert (allValues.size() == 4);

                    ownType_blobs_are_equal_check(allValues[0], ownType3Blob);
                    ownType_blobs_are_equal_check(allValues[1], ownType1Blob);
                    ownType_blobs_are_equal_check(allValues[2], ownType3Blob);
                    ownType_blobs_are_equal_check(allValues[3], ownType2Blob);

                },
            );
            test(
                "Multi blob: 'delete_all' test",
                func() {

                    let mem = lib.MemoryMultiHashList;

                    let memoryItem = lib.get_new_memory_storage();

                    let key1 : Blob = lib.Blobify.Text.to_blob("key1");
                    let key2 : Blob = lib.Blobify.Text.to_blob("key2");

                    let appendResult2 = mem.append(key1, memoryItem, ownType3Blob);
                    let appendResult3 = mem.append(key1, memoryItem, ownType2Blob);
                    let appendResult4 = mem.append(key1, memoryItem, ownType1Blob);
                    let appendResult5 = mem.append(key1, memoryItem, ownType3Blob);
                    let appendResult6 = mem.append(key1, memoryItem, ownType2Blob);

                    var result = mem.get_all(key1, memoryItem);
                    assert (result.size() == 5);

                    mem.delete_all(key1, memoryItem);

                    result := mem.get_all(key1, memoryItem);

                    assert (result == []);

                },
            );
            test(
                "Multi blob: 'append' test",
                func() {

                    let mem = lib.MemoryMultiHashList;

                    let memoryItem = lib.get_new_memory_storage();

                    let key1 : Blob = lib.Blobify.Text.to_blob("key1");
                    let key2 : Blob = lib.Blobify.Text.to_blob("key2");

                    let lastIndex : Nat = 100000;
                    for (index in Iter.range(0, lastIndex)) {
                        ignore mem.append(key1, memoryItem, ownType1Blob);
                    };

                    let all_adresses = mem.get_all_memory_addresses(key1, memoryItem);
                    assert (all_adresses.size() == lastIndex + 1);

                },
            );
        },

    );
