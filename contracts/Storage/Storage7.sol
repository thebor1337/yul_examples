// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract Storage7 {

    string public smallStr;
    string public bigStr;

    function writeAnyStr(string calldata, uint256) external {
        assembly {
            let ptr := mload(0x40)
            let cdSize := sub(calldatasize(), 4)
            calldatacopy(ptr, 4, cdSize)

            let strPos := add(ptr, mload(ptr))
            let slot := mload(add(ptr, 0x20))
            let strSize := mload(strPos)

            switch gt(strSize, 0xf)
            case 0 {
                storeShortString(slot, strPos)
            }
            default {
                storeLongString(slot, strPos)
            }

            function storeShortString(slotIdx, pos) {
                let size := mload(pos)
                let mask := 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00
                let _data := mload(add(pos, 0x20))
                _data := and(mask, _data)
                _data := or(_data, and(not(mask), mul(size, 2)))

                sstore(slotIdx, _data)
            }

            function storeLongString(slotIdx, pos) {
                let size := mload(pos) // in bytes

                sstore(slotIdx, add(mul(size, 2), 1))

                mstore(0x00, slotIdx)
                let strStorageLoc := keccak256(0x00, 0x20)

                let numSlots := div(size, 0x20)
                if mod(numSlots, 0x20) {
                    numSlots := add(numSlots, 1)
                }

                let dataPos := add(pos, 0x20)
                for { let i := 0 } lt(i, numSlots) { i := add(i, 1) } {
                    sstore(add(strStorageLoc, i), mload(dataPos))
                    dataPos := add(dataPos, 0x20)
                }
            }
        }
    }

    function writeSmallStr(string calldata) external {
        assembly {
            let ptr := mload(0x40)
            let cdSize := sub(calldatasize(), 4)
            calldatacopy(ptr, 4, cdSize)

            let slot := smallStr.slot
            let pos := add(ptr, mload(ptr))

            let size := mload(pos)
            if gt(size, 0xf) {
                revert(0, 0)
            }
            let mask := 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00
            let _data := mload(add(pos, 0x20))
            _data := and(mask, _data)
            _data := or(_data, and(not(mask), mul(size, 2)))

            sstore(slot, _data)
        }
    }

    function writeBigStr(string calldata) external {
        assembly {
            let ptr := mload(0x40)

            let cdSize := sub(calldatasize(), 4)
            calldatacopy(ptr, 4, cdSize)

            let slot := bigStr.slot
            let pos := add(ptr, mload(ptr))

            let strSize := mload(pos) // in bytes

            sstore(slot, add(mul(strSize, 2), 1))

            mstore(0x00, slot)
            let strStorageLoc := keccak256(0x00, 0x20)

            let numSlots := div(strSize, 0x20)
            if mod(numSlots, 0x20) {
                numSlots := add(numSlots, 1)
            }

            let dataPos := add(pos, 0x20)
            for { let i := 0 } lt(i, numSlots) { i := add(i, 1) } {
                sstore(add(strStorageLoc, i), mload(dataPos))
                dataPos := add(dataPos, 0x20)
            }
        }
    }

}