// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract Storage {

    uint256 x;
    uint256 public y;
    uint256 public z;
    uint128 public a;
    uint128 public b;

    function setX(uint256 _val) external {
        x = _val;
    }

    function getX() external view returns(uint256) {
        return x;
    }

    function getXYul() external view returns(uint256 ret) {
        assembly {
            ret := sload(x.slot)
        }
    }

    function getVarYul(uint256 _slot) external view returns(uint256 ret) {
        assembly {
            ret := sload(_slot)
        }
    }

    function getVarYulBytes(uint256 _slot) external view returns(bytes32 ret) {
        assembly {
            ret := sload(_slot)
        }
    }

    function setVarYul(uint256 _slot, uint256 _value) external {
        assembly {
            sstore(_slot, _value)
        }
    }
}