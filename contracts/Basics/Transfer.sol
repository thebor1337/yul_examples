// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract WithdrawV1 {
    address public owner;

    constructor() payable {
        owner = msg.sender;
    }

    function withdraw() external {
        (bool s, ) = payable(owner).call{value: address(this).balance}("");
        require(s);
    }
}

contract WithdrawV2 {
    address public owner;

    constructor() payable {
        owner = msg.sender;
    }

    function withdraw() external {
        assembly {
            let _owner := sload(0)
            let s := call(gas(), _owner, selfbalance(), 0, 0, 0, 0)
            if iszero(s) {
                revert(0, 0)
            }
        }
    }
}