// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract Storage4 {

    /// @dev it can be changed to any uintX type
    uint8[] smallArray;

    constructor() {
        // 0x0000000000000000000000000000000000000000000000000000000000030201 if uint8
        smallArray = [1, 2, 3];
    }

    function readSmallArrayLocation() external view returns(bytes32 ret) {
        uint256 slot;
        assembly {
            slot := smallArray.slot
        }
        bytes32 location = keccak256(abi.encode(slot));
        assembly {
            ret := sload(location)
        }
    }

    function readSmallArray(uint256 index, uint256 valueSizeBits) external view returns(uint256 value) {
        uint256 slot;
        assembly {
            slot := smallArray.slot
        }

        bytes32 zeroLocation = keccak256(abi.encode(slot));
        bytes32 slotValue;
        uint256 slotOffset;

        assembly {
            // 256 - num of bits in 1 slot, 8 - bits to encode one smallArray's element. So there can be 256 / 8 elements in a slot
            let elementsInSlot := div(256, valueSizeBits)
            let slotIdx := div(index, elementsInSlot)
            slotOffset := mod(index, elementsInSlot)
            slotValue := sload(add(zeroLocation, slotIdx))
        }

        value = extractValueFromSlotv1(slotValue, slotOffset * valueSizeBits, valueSizeBits);
    }

    function extractValueFromSlotv1(bytes32 slotValue, uint256 offsetBits, uint256 sizeBits) public pure returns(uint256 ret) {
        // slotValue = 0x0000000000000000000000000000000000000000000000000000000000030201
        assembly {
            // 0x0000000000000000000000000000000000000000000000000000000000000302
            let shifted := shr(offsetBits, slotValue)
            let shift := sub(256, sizeBits)
            // 0x0200000000000000000000000000000000000000000000000000000000000000
            let shifted2 := shl(shift, shifted)
            // 0x0000000000000000000000000000000000000000000000000000000000000002
            ret := shr(shift, shifted2)
        }
    }

    function extractValueFromSlotv2(bytes32 slotValue, uint256 offsetBits, uint256 sizeBits) public pure returns(uint256 ret, bytes32 mask) {
        // slotValue = 0x0000000000000000000000000000000000000000000000000000000000030201
        // offsetBits = 8
        // sizeBits = 8

        assembly {
            // 0x0000000000000000000000000000000000000000000000000000000000000302
            let shifted := shr(offsetBits, slotValue)

            switch eq(sizeBits, 256)
            case 0 {
                // example:
                // need: 0x00000000000000000000000000000000000000000000000000000000000000ff
                // 2^256 - 1 = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
                // 2^8 - 1 = 0xff or 0x00000000000000000000000000000000000000000000000000000000000000ff
                mask := sub(exp(2, sizeBits), 1)
            }
            default {
                mask := 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
            }

            // 0x0000000000000000000000000000000000000000000000000000000000000302
            // and
            // 0x00000000000000000000000000000000000000000000000000000000000000ff
            // 0x0000000000000000000000000000000000000000000000000000000000000002
            ret := and(mask, shifted)
        }
    }

    function writeFixedSmallArray(uint256 index, uint256 newValue, uint256 valueSizeBits) public {
        uint256 slot;
        assembly {
            slot := smallArray.slot
        }

        bytes32 zeroLocation = keccak256(abi.encode(slot));
        bytes32 slotValue;
        uint256 slotOffset;
        bytes32 slotLocation;
        assembly {
            let elementsInSlot := div(256, valueSizeBits)
            let slotIdx := div(index, elementsInSlot)
            slotOffset := mul(mod(index, elementsInSlot), valueSizeBits)
            slotLocation := add(zeroLocation, slotIdx)
            slotValue := sload(slotLocation)
        }

        bytes32 replacedSlot = getReplacedSlotValue(slotValue, slotOffset, valueSizeBits, newValue);

        assembly {
            sstore(slotLocation, replacedSlot)
        }
    }

    function writeDynamicSmallArray(uint256 index, uint256 newValue, uint256 valueSizeBits) external {
        assembly {
            let slot := smallArray.slot
            let length := sload(slot)
            let needUpdateLength := 0
            let cond := eq(length, 0)

            switch eq(length, 0)
            case 0 {
                if gt(index, sub(length, 1)) {
                    needUpdateLength := 1
                }
            }
            default {
                needUpdateLength := 1
            }

            if needUpdateLength {
                sstore(slot, add(length, 1))
            }
        }

        writeFixedSmallArray(index, newValue, valueSizeBits);
    }

    function getReplacedSlotValue(bytes32 slotValue, uint256 offsetBits, uint256 sizeBits, uint256 newValue) public pure returns(bytes32 ret) {

        // 0x0000000000000000000000000000000000000000000000000000000000030201 - slotValue
        // 0x0000000000000000000000000000000000000000000000000000000000000052 - newValue
        // 0x0000000000000000000000000000000000000000000000000000000000000008 - offsetBits
        // 0x0000000000000000000000000000000000000000000000000000000000000008 - sizeBits

        assembly {
            let mask := 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff

            // 0x000000000000000000000000000000000000000000000000000000000000ffff
            let mask1 := sub(exp(2, add(offsetBits, sizeBits)), 1)
            // 0x00000000000000000000000000000000000000000000000000000000000000ff
            let mask2 := sub(exp(2, offsetBits), 1)
            // 0x000000000000000000000000000000000000000000000000000000000000ff00
            let mask3 := sub(mask1, mask2)

            // (2**256-1) - ((2**16-1) - (2**8 - 1))
            // 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00ff
            mask := sub(mask, mask3)

            // 0x0000000000000000000000000000000000000000000000000000000000030201 // slotValue
            // 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00ff // mask
            // 0x0000000000000000000000000000000000000000000000000000000000030001 // AND
            let clearedValue := and(slotValue, mask)
            // 0x0000000000000000000000000000000000000000000000000000000000005200
            let shiftedNewValue := shl(offsetBits, newValue)

            // 0x0000000000000000000000000000000000000000000000000000000000030001 // clearedValue
            // 0x0000000000000000000000000000000000000000000000000000000000005200 // shiftedNewValue
            // 0x0000000000000000000000000000000000000000000000000000000000035201 // OR
            ret := or(clearedValue, shiftedNewValue)
        }
    }

    function getSmallArraySol(uint256 index) external view returns(uint256) {
        return smallArray[index];
    }
}