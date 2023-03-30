// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract IsPrime {

    function isPrimeSol(uint256 x) external pure returns(bool) {
        uint256 halfX = (x / 2) + 1;
        for (uint256 i = 2; i < halfX; i++) {
            if (x % i == 0) {
                return false;
            }
        }
        return true;
    }

    function isPrime(uint256 x) external pure returns(bool p) {
        p = true;
        assembly {
            let halfX := add(div(x, 2), 1)
            for { let i := 2 } lt(i, halfX) { i:= add(i, 1) }
            {
                if iszero(mod(x, i)) { // or if eq(mod(x, i), 0)
                    p := 0
                    break
                }
            }
        }
    }

    function isPrime2(uint256 x) external pure returns(bool p) {
        p = true;
        assembly {
            let halfX := add(div(x, 2), 1)
            let i := 2
            for { } lt(i, halfX) { } 
            {
                if iszero(mod(x, i)) {
                    p := 0
                    break
                }
                i := add(i, 1)
            }
        }
    }
}