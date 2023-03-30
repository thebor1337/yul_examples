// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Memory2 {

    uint8[] foo = [6, 5, 4, 3, 2, 1];

    function breakFreeMemoryPointer(uint256[1] memory _foo) external pure returns(uint256) {
        assembly {
            mstore(0x40, 0x80)
        }
        // rewrites foo, because free memory pointer is pointing at 0x80 now, where _foo is stored
        uint256[1] memory bar = [uint256(6)];
        return _foo[0];
    }

    function unpacked() external view returns(uint256 first, uint256 second) {
        // foo is stored into a single slot, but while storing to memory it'll be unpacked as uint256 values
        uint8[] memory bar = foo;

        assembly {
            first := mload(add(0x80, 0x20))
            second := mload(add(add(0x80, 0x20), 0x20)) // a signle values takes up 32 bytes, not 1 byte (as expected for uint8)
        }
    }

    function return2And4() external pure returns(uint256, uint256) {
        assembly {
            mstore(0x00, 2)
            mstore(0x20, 4)
            return (0x00, 0x40)
        }
    }

    function requireSender() external view {
        // require(msg.sender == 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2)
        assembly {
            if iszero(eq(caller(), 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2)) {
                revert(0, 0)
            }
        }
    }

    function hash1() external pure returns(bytes32) {
        bytes memory toHash = abi.encode(1, 2, 3);
        return keccak256(toHash);
    }

    function hash2() external pure returns(bytes32) {
        assembly {
            // getting free memory pointer
            let freeMemoryPointer := mload(0x40)

            // writing [1,2,3] since free memory pointer's value
            mstore(freeMemoryPointer, 1)
            mstore(add(freeMemoryPointer, 0x20), 2)
            mstore(add(freeMemoryPointer, 0x40), 3)

            // updating free memory pointer to the actual closest free slot
            mstore(0x40, add(freeMemoryPointer, 0x60))

            // storing hash to 0x00-0x20
            mstore(0x00, keccak256(freeMemoryPointer, 0x60))
            return(0x00, 0x20)
        }
    }
}