// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract Storage5 {

    mapping(uint256 => uint256) public myMapping;
    mapping(uint256 => mapping(uint256 => uint256)) public nestedMapping;
    mapping(address => uint256[]) public addressToList;

    constructor() {
        myMapping[10] = 20;
        myMapping[20] = 40;
        myMapping[40] = 80;

        nestedMapping[5][10] = 20;
        nestedMapping[10][15] = 40;
        nestedMapping[15][20] = 80;

        addressToList[0x5B38Da6a701c568545dCfcB03FcB875f56beddC4] = [1, 2, 3];
        addressToList[0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2] = [10, 20, 30, 40];        
    }

    function getMapping(uint256 key) external view returns(uint256 ret) {
        uint256 slot;
        assembly {
            slot := myMapping.slot
        }

        bytes32 location = keccak256(abi.encode(key, slot));

        assembly {
            ret := sload(location)
        }
    }

    function getNestedMapping(uint256 key1, uint256 key2) external view returns(uint256 ret) {
        uint256 slot;
        assembly {
            slot := nestedMapping.slot
        }

        // bytes32 location = keccak256(abi.encode(key1, slot));
        // location = keccak256(abi.encode(key2, location));

        bytes32 location = keccak256(
            abi.encode(
                key2, 
                keccak256(abi.encode(key1, slot))
            )
        );

        assembly {
            ret := sload(location)
        }
    }

    function getAddressValue(address addr, uint256 index) external view returns(uint256 ret) {
        uint256 slot;
        assembly {
            slot := addressToList.slot
        }

        // bytes32 mappingLocation = keccak256(abi.encode(uint256(uint160(addr)), slot));
        // bytes32 arrayLocation = keccak256(abi.encode(mappingLocation));

        bytes32 arrayLocation = keccak256(
            abi.encode(
                keccak256(abi.encode(
                    uint256(uint160(addr)), slot
                ))
            )
        );

        assembly {
            ret := sload(add(arrayLocation, index))
        }
    }
} 