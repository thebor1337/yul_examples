// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract Storage10 {

    uint256[] public myArr = [1,2,3];
    bytes public myBytes;

    function getArrLength(uint256[] storage data) internal view returns(bytes32) {
        assembly {
            mstore(0x00, sload(data.slot))
            return(0x00, 0x20)
        }
    }

    function proxy() external view returns(bytes32) {
        return getArrLength(myArr);
    }
}