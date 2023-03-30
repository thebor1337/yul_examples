// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract RevertError {

    function revertSomeError() external pure {
        assembly {
            let ptr := mload(0x40) // Get free memory pointer
            mstore(ptr, 0x08c379a000000000000000000000000000000000000000000000000000000000) // Selector for method Error(string)
            mstore(add(ptr, 0x04), 0x20) // String offset
            mstore(add(ptr, 0x24), 30) // Revert reason length
            mstore(add(ptr, 0x44), "some error")
            revert(ptr, 0x64)
        }
    }

    function revertString(string calldata error) external pure {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x08c379a000000000000000000000000000000000000000000000000000000000)
            mstore(add(ptr, 0x04), 0x20)
            mstore(add(ptr, 0x24), error.length)
            calldatacopy(add(ptr, 0x44), error.offset, error.length)

            let size
            let diff := mod(error.length, 0x20)
            switch diff
            case 0 {
                size := error.length
            }
            default {
                size := add(error.length, sub(0x20, diff))
            }

            revert(ptr, add(0x44, size))
        }
    }

    function revertCustomError(uint256 errorType) external pure {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x08c379a000000000000000000000000000000000000000000000000000000000)
            mstore(add(ptr, 0x04), 0x20)
            let startPos := add(ptr, 0x24)
            
            let size
            switch errorType
            case 0 {
                size := 0x40
                mstore(startPos, 37)
                mstore(add(startPos, 0x20), "ERC20: decreased allowance below")
                mstore(add(startPos, 0x40), " zero")
            }
            case 1 {
                size := 0x40
                mstore(startPos, 37)
                mstore(add(startPos, 0x20), "ERC20: transfer from the zero ad")
                mstore(add(startPos, 0x40), "dress")
            }
            default {
                revert(0, 0)
            }

            revert(ptr, add(0x44, size))
        }
    }
}