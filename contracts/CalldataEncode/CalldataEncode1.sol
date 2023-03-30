// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract Executor {

    struct TestStruct {
        uint8 a;
        uint32 b;
        uint256 c;
    }

    // v1(uint256[],uint256[]) -> 6c5f9c7f
    function v1(uint256[] calldata data1, uint256[] calldata data2) external pure returns(bool) {
        require(data1.length == data2.length, "invalid");
        for (uint256 i = 0; i < data1.length; i++) {
            if (data1[i] != data2[i]) {
                return false;
            }
        }
        return true;
    }

    // v2(uint256,uint256[],uint256[]) -> 6929df95
    function v2(uint256 max, uint256[] calldata data1, uint256[] calldata data2) external pure returns(bool) {
        require(data1.length <= max && data1.length == data2.length, "invalid");
        for (uint256 i = 0; i < data1.length; i++) {
            if (data1[i] != data2[i]) {
                return false;
            }
        }
        return true;
    }

    // structHandler((uint8,uint32,uint256)) -> ae515f3d
    function structHandler(TestStruct calldata data) external pure returns(uint256) {
        return data.a + data.b + data.c;
    }
}

contract FuncEncode {
    function returnDynamicBytes() external pure returns(bytes memory) {
        assembly {
            mstore(0x00, 0x20) // where to start decoding
            mstore(0x20, 0x20) // length
            mstore(0x40, 0x5fa88e2a) // value
            return(0x00, 0x60)
        }
    }

    function returnDynamicBytesWithShift() external pure returns(bytes memory) {
        assembly {
            // Inner memory locations are independent from function memory locations
            mstore(0x20, 0x20) // where to start decoding
            mstore(0x40, 0x20) // length
            mstore(0x60, 0x5fa88e2a) // value
            return(0x20, 0x60)
        }
    }

    function test1() external pure returns(uint[] memory) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x20)
            
            mstore(add(ptr, 0x20), 3)
            mstore(add(ptr, 0x40), 1)
            mstore(add(ptr, 0x60), 2)
            mstore(add(ptr, 0x80), 3)

            return(ptr, add(ptr, 0xa0))
        }
    }

    function test2() external pure returns(uint[] memory, uint[] memory) {
        assembly {
            let ptr := mload(0x40)
            
            mstore(ptr, 0x40) // where to start decoding the first array
            mstore(add(ptr, 0x20), 0xc0) // where to start decoding the second array

            mstore(add(ptr, 0x40), 3) // length of the first array
            mstore(add(ptr, 0x60), 1)
            mstore(add(ptr, 0x80), 2)
            mstore(add(ptr, 0xa0), 3)

            mstore(add(ptr, 0xc0), 3) // length of the second array
            mstore(add(ptr, 0xe0), 4)
            mstore(add(ptr, 0x100), 5)
            mstore(add(ptr, 0x120), 6)

            return(ptr, 0x140)
        }
    }

    function callV1(address _a) external view returns(bool) {
        assembly {
            let ptr := mload(0x40)

            mstore(ptr, 0x6c5f9c7f)

            let innerPtr := add(ptr, 0x20)

            mstore(add(innerPtr, 0x00), 0x40) // where to start decoding the first array
            mstore(add(innerPtr, 0x20), 0xc0) // where to start decoding the second array

            mstore(add(innerPtr, 0x40), 3) // length of the first array
            mstore(add(innerPtr, 0x60), 1)
            mstore(add(innerPtr, 0x80), 2)
            mstore(add(innerPtr, 0xa0), 3)

            mstore(add(innerPtr, 0xc0), 3) // length of the second array
            mstore(add(innerPtr, 0xe0), 1)
            mstore(add(innerPtr, 0x100), 2)
            mstore(add(innerPtr, 0x120), 3)

            mstore(0x40, add(innerPtr, 0x140))

            let success := staticcall(gas(), _a, add(ptr, 28), 0x144, 0x00, 0x20)
            if iszero(success) {
                revert(0, 0)
            }

            return(0x00, 0x20)
        }
    }

    function callV2(address _a) external view returns(bool) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x6929df95)

            let innerPtr := add(ptr, 0x20)
            mstore(add(innerPtr, 0x00), 3) // uint256 max

            mstore(add(innerPtr, 0x20), 0x60) // where to start decoding the first array
            mstore(add(innerPtr, 0x40), 0xe0) // where to start decoding the second array

            mstore(add(innerPtr, 0x60), 3) // length of the first array
            mstore(add(innerPtr, 0x80), 1)
            mstore(add(innerPtr, 0xa0), 2)
            mstore(add(innerPtr, 0xc0), 3)

            mstore(add(innerPtr, 0xe0), 3) // length of the second array
            mstore(add(innerPtr, 0x100), 1)
            mstore(add(innerPtr, 0x120), 2)
            mstore(add(innerPtr, 0x140), 3)

            // updating ptr
            mstore(0x40, add(innerPtr, 0x160))

            let success := staticcall(gas(), _a, add(ptr, 28), 0x164, 0x00, 0x20)
            if iszero(success) {
                revert(0, 0)
            }

            return(0x00, 0x20)
        }
    }

    function callStructTest(address _a) external view returns(uint256) {
        assembly {
            let ptr := mload(0x40)

            mstore(ptr, 0xae515f3d)

            mstore(add(ptr, 0x20), 10)
            mstore(add(ptr, 0x40), 5)
            mstore(add(ptr, 0x60), 3)

            let success := staticcall(gas(), _a, add(ptr, 28), add(0x60, 4), 0x00, 0x20)
            if iszero(success) {
                revert(0, 0)
            }
            return(0x00, 0x20)
        }
    }
}
