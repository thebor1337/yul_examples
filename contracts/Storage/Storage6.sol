// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract Storage6 {

    string public smallStr = "lorem";
    string public bigStr = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.222";
    string public emptyStr = "";

    function readSmallStr() external view returns(string memory) {
        assembly {
            let slot := smallStr.slot
            let data := sload(slot)
            let mask := 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00
            let length := and(not(mask), data)
            let value := and(mask, data)

            mstore(0x00, 0x20)
            mstore(add(0x00, 0x20), div(length, 2))
            mstore(add(0x00, 0x40), value)    

            return(0x00, 0x60)
        }
    }

    function readBigStr() external view returns(string memory) {
        assembly {
            let slot := bigStr.slot
            let length := div(sub(sload(slot), 1), 2)
            mstore(0x00, slot)

            let strLocation := keccak256(0x00, 0x20)
            let numSlots := div(length, 0x20)
            if mod(length, 0x20) { // non zero
                numSlots := add(numSlots, 1)
            }

            mstore(0x00, 0x20)
            mstore(add(0x00, 0x20), length)

            let ptr := 0x40
            for { let i := 0 } lt(i, numSlots) { i := add(i, 1) }
            {
                mstore(add(0x00, ptr), sload(add(strLocation, i)))
                ptr := add(ptr, 0x20)
            }

            return(0x00, ptr)
        }
    }

    function readAnyStr(uint256 slot) external view returns(string memory) {

        assembly {
            function copyBytes(slotIdx, startPos) -> b {
                let data := sload(slotIdx)
                switch and(data, 0xff00000000000000000000000000000000000000000000000000000000000000)
                case 0 {
                    b := copyLongBytes(slotIdx, startPos, data)
                }
                default {
                    b := copyShortBytes(startPos, data)
                }
            }

            function copyShortBytes(startPos, slotData) -> b {
                let mask := 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00
                let length := div(and(not(mask), slotData), 2)
                let value := and(mask, slotData)

                mstore(startPos, 0x20)
                mstore(add(startPos, 0x20), length)
                mstore(add(startPos, 0x40), value)    

                b := 0x60
            }

            function copyLongBytes(slotIdx, startPos, slotData) -> b {
                let length := div(sub(slotData, 1), 2)
                mstore(0x00, slotIdx)

                let strLocation := keccak256(0x00, 0x20)
                let numSlots := div(length, 0x20)
                if mod(length, 0x20) { // non zero
                    numSlots := add(numSlots, 1)
                }

                mstore(startPos, 0x20)
                mstore(add(startPos, 0x20), length)

                b := 0x40
                for { let i := 0 } lt(i, numSlots) { i := add(i, 1) }
                {
                    mstore(add(startPos, b), sload(add(strLocation, i)))
                    b := add(b, 0x20)
                }
            }

            let b := copyBytes(slot, 0x00)
            return(0x00, b)
        }
    }
}