// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract Logs {

    event SomeLog(uint256 indexed a, uint256 indexed b);
    event SomeLog2(uint256 indexed a, bool);

    function emitLog() external {
        emit SomeLog(5, 6);
    }

    function yulEmitLog() external {
        assembly {
            // keccak256(SomeLog(uint256,uint256)
            let signature := 0xc200138117cf199dd335a2c6079a6e1be01e6592b6a76d4b5fc31b169df819cc
            log3(0, 0, signature, 5, 6)
        }
    }

    function emitLog2() external {
        emit SomeLog2(5, false);
    }

    function yulEmitLog2() external {
        assembly {
            // keccak256(uint256,bool)
            let signature := 0xaefa010f939214fae1e59fb086529644424f237026307231d77d0d2405f03a5d
            mstore(0x00, 0)
            log2(0x00, 0x20, signature, 5)
        }
    }
}