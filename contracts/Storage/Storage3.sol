// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract Storage3 {

    uint256[3] fixedArray;
    uint256[] dynArray;

    constructor() {
        fixedArray = [99, 999, 9999];
        dynArray = [10, 20, 30];
    }

    function getFixedArraySol(uint256 index) external view returns(uint256) {
        return fixedArray[index];
    }

    function readFixedArray(uint256 index) external view returns(uint256 ret) {
        assembly {
            ret := sload(add(fixedArray.slot, index))
        }
    }

    function writeFixedArray(uint256 index, uint256 value) external {
        require(index < 3);
        assembly {
            sstore(add(fixedArray.slot, index), value)
        }
    }

    function dynArrayLength() external view returns(uint256 ret) {
        assembly {
            ret := sload(dynArray.slot)
        }
    }

    function getDynArraySol(uint256 index) external view returns(uint256) {
        return dynArray[index];
    }

    function readDynArray(uint256 index) external view returns(uint256 ret) {
        uint256 slot;
        assembly {
            slot := dynArray.slot
        }
        bytes32 location = keccak256(abi.encode(slot));
        assembly {
            ret := sload(add(location, index))
        }
    }

    function writeDynArray(uint256 index, uint256 value) external {
        uint256 slot;
        assembly {
            slot := dynArray.slot
            let length := sload(slot)
            let needUpdateLength := 0
            let cond := eq(length, 0)

            switch cond
            case 0 {
                if gt(index, sub(length, 1)) {
                    needUpdateLength := 1
                }
            }
            default {
                needUpdateLength := 1
            }

            if needUpdateLength {
                sstore(slot, add(length, sub(index, sub(length, 1))))
            }
        }

        bytes32 location = keccak256(abi.encode(slot));

        assembly {
            sstore(add(location, index), value)
        }
    }
}