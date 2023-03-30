// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract CalldataEncode3 {
    
    struct TestStruct {
        uint256 a;
        uint256 b;
    }

    function decodeBytes(bytes calldata data) external pure returns(bytes memory) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x20)
            mstore(add(ptr, 0x20), data.length)
            calldatacopy(add(ptr, 0x40), data.offset, data.length)
            // add one more 0x20 to handle the case when data.length % 0x20 != 0 (not occupied all 32 bytes in the last slot)
            return(ptr, add(0x60, data.length))
        }
    }

    function decodeArray(uint256[] calldata data) external pure returns(uint256[] memory) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x20)
            mstore(add(ptr, 0x20), data.length)
            let size := mul(data.length, 0x20)
            calldatacopy(add(ptr, 0x40), data.offset, size)
            return(ptr, add(0x40, size))
        }
    }

    function decodeStruct(TestStruct calldata data) external pure returns(TestStruct memory) {
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, data, 0x40) // data = offset
            return(ptr, 0x40)
        }
    }

    function decodeMemoryBytes(bytes memory data) external pure returns(bytes memory) {
        assembly {
            let length := mload(data) // data = offset
            let ptr := sub(data, 0x20)
            mstore(ptr, 0x20)
            return(ptr, add(0x60, length))
        }
    }
}