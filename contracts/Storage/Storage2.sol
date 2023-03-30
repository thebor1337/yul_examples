// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract Storage2 {

    uint128 public C = 4;
    uint96 public D = 6;
    uint16 public E = 8;
    uint8 public F = 1;

    // uint128-uint96-uint16-uint8
    // 0x 00 01 0008 000000000000000000000006 00000000000000000000000000000004
    // uint32-uint96-uint16-uint8
    // 0x 00000000000000000000000000 01 0008 000000000000000000000006 00000004
    // uint128-uint96-uint24-uint8
    // 0x 01 000008 000000000000000000000006 00000000000000000000000000000004
    // it stores ordered variables from left to right and leaves trailing zeros if not enough valuable bytes

    function readBySlot(uint256 slot) external view returns(bytes32 ret) {
        assembly {
            ret := sload(slot)
        }
    }

    function getOffsetE() external pure returns(uint256 slot, uint256 offset) {
        assembly {
            slot := E.slot
            offset := E.offset
        }
    }

    function readEv1() external view returns(uint256 e) {
        assembly {
            // 0x0001000800000000000000000000000600000000000000000000000000000004
            let value := sload(E.slot)
            // 0x0000000000000000000000000000000000000000000000000000000000010008
            let shifted := shr(mul(E.offset, 8), value) // 8 (bits in 1 byte) * 28 (offset) => shifting (removing) 224 bits 
            // 0x000000000000000000000000000000000000000000000000000000000000ffff // 0xffff
            // 0x0000000000000000000000000000000000000000000000000000000000010008 // shifted
            // 0x0000000000000000000000000000000000000000000000000000000000000008 // AND
            e := and(0xffff, shifted)
        }
    }

    function readEv2() external view returns(uint256 e, bytes32 shifted, bytes32 value) {
        assembly {
            let slot := E.slot // => 0
            let offset := E.offset // => 28
            value := sload(slot) // 256 bits = 32 bytes = 64 hex

            // 1 hex = 4 bits => 2 hex = 8 bits = 1 byte
            // example: 0x5500 / 0x0100 = 0x0055 => to shift 2 hex, needs to div by 0x100

            // need to shift 28 bytes = (28*2) = 56 hex
            // 64 hex / 56 hex => shifting to right for 28 hex => 8 hex remaining

            // 0x 00010008 00000000000000000000000600000000000000000000000000000004 // value
            // 0x        1 00000000000000000000000000000000000000000000000000000000
            // 0x 00000000000000000000000000000000000000000000000000000000 00010008 // DIV
            shifted := div(value, 0x100000000000000000000000000000000000000000000000000000000)
            // 0x 00000000000000000000000000000000000000000000000000000000 00010008 // shifted
            // 0x 00000000000000000000000000000000000000000000000000000000 0000ffff // mask
            // 0x 00000000000000000000000000000000000000000000000000000000 00000008 // AND
            e := and(0xffff, shifted)
        }
    }

    function writeE(uint16 newE) external {
        // Masks basic:
        // V and 00 = 00
        // V and FF = V
        // V or  00 = V

        // let newE = 10
        assembly {
            // despite newE is uint16, in Yul it's 32 bytes under hood. it works for any args
            // newE = 0x000000000000000000000000000000000000000000000000000000000000000a
            let c := sload(E.slot)

            // 0xffff 0000 ffffffffffffffffffffffffffffffffffffffffffffffffffffffff // mask
            // 0x0001 0008 00000000000000000000000600000000000000000000000000000004 // c
            // 0x0001 0000 00000000000000000000000600000000000000000000000000000004 // AND
            let clearedE := and(c, 0xffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffff)

            // 0x0000000a00000000000000000000000000000000000000000000000000000000
            let shiftedNewE := shl(mul(E.offset, 8), newE)

            // 0x 0000 000a 00000000000000000000000000000000000000000000000000000000 // shiftedNewE
            // 0x 0001 0000 00000000000000000000000600000000000000000000000000000004 // clearedE
            // 0x 0001 000a 00000000000000000000000600000000000000000000000000000004 // OR
            let newVal := or(shiftedNewE, clearedE)
            
            sstore(E.slot, newVal)
        }
    }
}