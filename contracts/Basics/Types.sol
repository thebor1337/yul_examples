// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract YulTypes {
    function getNumber() external pure returns(uint256) {
        uint256 x;
        assembly {
            x := 42
        }
        return x;
    }

    function getHex() external pure returns(uint256) {
        uint256 x;
        assembly {
            x := 0xa
        }
        return x;
    }

    function getString() external pure returns(string memory) {
        bytes32 myString = "";
        assembly {
            // no longer than 32 bytes string
            myString := "hello world"
        }
        return string(abi.encode(myString));
    }

    function boolRepr() external pure returns(bool) {
        bool x;
        assembly {
            x := 1
        }
        return x;
    }

    function uint16Repr() external pure returns(uint16) {
        uint16 x;
        assembly {
            x := 1
        }
        return x;
    }

    function addressRepr() external pure returns(address) {
        address x;
        assembly {
            x := 52 // 52 = 0x34, 0x52 - 1:1
        }
        return x;
    }
}