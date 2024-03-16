import HashListTypes "hashListTypes";
import Nat64 "mo:base/Nat64";
import KeyInfoTypes "keyInfo/keyInfoTypes";
import MemoryStorageTypes "memoryStorage/memoryStorageTypes";
import WrappedBlobTypes "wrappedBlob/wrappedBlobTypes";
import IndexTableTypes "indexTable/indexTableTypes";
import IndexTableHeaderTypes "indexTable/indexTableHeaderTypes";
import ResponsResultTypes "response/responseResultTypes";

module {

    /*
    big primes (less than 64 bit)
    
    1152921504606847255
    2251799813685495
    288230376151711885
    2305843009213693723
    1125899906842755
    */

    // Identifiers:
    public let identifier_WrappedBlob : Nat64            = 144115188075855599;
    public let identifier_KeyInfo:Nat64                  = 576460752303422881;
    public let identifier_IndexTableHeader:Nat64         = 36028797018963797;
    public let identifier_MainIndexTable:Nat64           = 72057594037928125;
    public let identifier_ParentIndexTable:Nat64         = 4611686018427388107;
   
    public type MemoryStorage = MemoryStorageTypes.MemoryStorage;

    // Offsets
    public let Offsets_KeyInfo = KeyInfoTypes.Offsets_KeyInfo;
    public let Offsets_WrappedBlob = WrappedBlobTypes.Offsets_WrappedBlob;
    public let Offsets_IndexTableHeader = IndexTableHeaderTypes.Offsets_IndexTableHeader;
    public let Offset_IndexTable = IndexTableTypes.Offset_IndexTable;

    public type ResponseResult = ResponsResultTypes.ResponseResult;

};
