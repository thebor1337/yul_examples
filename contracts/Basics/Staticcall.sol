// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract OtherContract {

    // x() -> 0c55699c
    uint256 public x;

    // arr(uint256) -> 71e5ee5f
    uint256[] public arr;

    // get21() -> 9a884bde
    function get21() external pure returns(uint256) {
        assembly {
            mstore(0x00, 21)
            return(0x00, 0x20)
        }
    }

    // revertWith999() -> 73712595
    function revertWith999() external pure {
        assembly {
            mstore(0x00, 999)
            revert(0x00, 0x20)
        }
    }

    // multiply(uint128,uint16) -> 196e6d84
    function multiply(uint128 _x, uint16 _y) external pure returns(uint256) {
        return _x * _y;
    }

    // setX(uint256) -> 4018d9aa
    function setX(uint256 _x) external {
        x = _x;
    }

    // variableReturnLength(uint256) -> 7c70b4db
    function variableReturnLength(uint256 len) external pure returns(bytes memory) {
        bytes memory ret = new bytes(len);
        for (uint256 i = 0; i < len; i++) {
            ret[i] = 0xab;
        }
        return ret;
    }

    // checkMemory() -> 52800037
    function checkMemory() external pure returns(bytes32) {
        assembly {
            mstore(0xa0, 100)
            return(0x80, 0x20)
        }
    }

    // multipleVariableLength(uint256[],uint256[]) -> 5fa88e2a
    function multipleVariableLength(uint256[] calldata data1, uint256[] calldata data2) external pure returns(bool) {
        require(data1.length == data2.length, "invalid");
        for (uint256 i = 0; i < data1.length; i++) {
            if (data1[i] != data2[i]) {
                return false;
            }
        }
        return true;
    }

    function multipleVariableLength2(uint256 max, uint256[] calldata data1, uint256[] calldata data2) external pure returns(bool) {
        require(data1.length < max && data1.length == data2.length, "invalid");
        for (uint256 i = 0; i < data1.length; i++) {
            if (data1[i] != data2[i]) {
                return false;
            }
        }
        return true;
    }
}

contract ExternalCalls {

    function externalViewCallNoArgs(address _a) external view returns(uint256) {
        assembly {
            mstore(0x00, 0x9a884bde)
            // let success := staticcall(gas(), _a, 28, 4, 0x00, 0x20)
            let success := staticcall(gas(), _a, 0x1c, 0x04, 0x00, 0x20)
            if iszero(success) {
                revert(0, 0)
            }
            return(0x00, 0x20)
        }
    }

    function getViaReturn(address _a) external view returns(uint256) {
        assembly {
            mstore(0x00, 0x73712595)
            pop(staticcall(gas(), _a, 28, 32, 0x00, 0x20))
            return(0x00, 0x20)
        }
    }

    function callMultiply(address _a) external view returns(uint256) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x196e6d84)
            mstore(add(ptr, 0x20), 3)
            mstore(add(ptr, 0x40), 11)
            mstore(0x40, add(ptr, 0x60))
            let success := staticcall(gas(), _a, add(ptr, 28), mload(0x40), 0x00, 0x20)
            if iszero(success) {
                revert(0, 0)
            }
            return(0x00, 0x20)
        }
    }

    function externalStateChangingCall(address _a) external returns(uint256) {
        assembly {
            mstore(0x00, 0x4018d9aa)
            mstore(0x20, 5)
            let success := call(gas(), _a, callvalue(), add(0x00, 28), 0x40, 0x00, 0x00)
            if iszero(success) {
                revert(0, 0)
            }
            mstore(0x00, 0x0c55699c)
            success := staticcall(gas(), _a, add(0x00, 28), 0x20, 0x00, 0x20)
            if iszero(success) {
                revert(0, 0)
            }
            return(0x00, 0x20)
        }
    }

    function unknownSizeCall(address _a, uint256 _amount) external view returns(bytes memory) {
        assembly {
            mstore(0x00, 0x7c70b4db)
            mstore(0x20, _amount)
            let success := staticcall(gas(), _a, 28, 64, 0x00, 0x00)
            if iszero(success) {
                revert(0, 0)
            }
            returndatacopy(0, 0, returndatasize())
            return(0, returndatasize())
        }
    }

    function checkMemory(address _a) external view returns(bytes32, bytes32) {
        assembly {
            let ptr := 0x80
            mstore(ptr, 0x52800037)
            let success := staticcall(gas(), _a, add(ptr, 28), 4, 0x00, 0x20)
            if iszero(success) {
                revert(0, 0)
            }
            mstore(0x20, mload(0xa0))
            return(0x00, 0x40)
        }
    }
}