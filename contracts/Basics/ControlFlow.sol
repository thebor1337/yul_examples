// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract IfComparsion {

    function isTruthy() external pure returns(uint256 result) {
        result = 2;
        assembly {
            if 2 { // smth more or equal to 1
                result := 1
            }
        }
    }

    function isFalsy() external pure returns(uint256 result) {
        result = 2;
        assembly {
            if 0 { // smth more or equal to 1
                result := 1
            }
        }
    }

    function negation(bool _switcher) external pure returns(uint256 result) {
        result = 2;
        assembly {
            if iszero(_switcher) {
                result := 1
            }
        }
    }

    function demoFlip(uint i) external pure returns(bytes32 result) {
        assembly {
            result := not(i)
        }
    }

    function max(uint256 x, uint256 y) external pure returns(uint256 maximum) {
        assembly {
            if lt(x, y) {
                maximum := y
            }
            if iszero(lt(x, y)) {
                maximum := x
            }
        }
    }

    function switcher(uint8 val) external pure returns(uint256 p) {
        assembly {
            switch gt(val, 100)
            case 0 {
                p := add(val, 50)
            }
            default {
                p := sub(val, 50)
            }
        }
    }
}