// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract CalldataEncode2 {
    
    function encodeDifferentOutputs() external pure returns(bytes4, uint8) {
        assembly {
            let ptr := mload(0x40)

            mstore(ptr, shl(224, 0x6c5f9c7f))
            mstore(add(ptr, 0x20), 5)

            return(ptr, 0x40)
        }
    }

    function encodeTypeNReferenceOutputs() external pure returns(bytes4, uint256[] memory) {
        assembly {
            let ptr := mload(0x40)

            mstore(ptr, shl(224, 0x6c5f9c7f))

            mstore(add(ptr, 0x20), 0x40)
            mstore(add(ptr, 0x40), 3)
            mstore(add(ptr, 0x60), 10)
            mstore(add(ptr, 0x80), 20)
            mstore(add(ptr, 0xa0), 30)

            return(ptr, 0xc0)
        }
    }

    function getSelector() external pure returns(bytes4) {
        assembly {
            let selector := calldataload(0)
            mstore(0x00, selector)
            return(0x00, 0x20)
        }
    }

    function getSelectorNTypeData(uint256) external pure returns(bytes4, uint256) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, calldataload(0))
            mstore(add(ptr, 0x20), calldataload(4))
            return(ptr, 0x40)
        }
    }

    function takeNReturnArr(uint8[] memory) external pure returns(uint8[] memory) {
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 4, sub(calldatasize(), 4))
            return(ptr, calldatasize())
        }
    }

    function takeNReturnData1(uint8, uint16[] memory) external pure returns(uint8, uint16[] memory) {
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 4, 0x20)
            calldatacopy(add(ptr, 0x20), 0x24, sub(calldatasize(), 0x24))
            return(ptr, calldatasize())
        }
    }

    function returnString() external pure returns(string memory) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x20) // memory pointer where the string starts
            mstore(add(ptr, 0x20), 3) // number of bytes
            mstore(add(ptr, 0x40), shl(232, 0x687579)) // utf8 bytes (0x395743853400000000, not vice versa)
            return(ptr, 0x60)
        }
    }

    // Decodes custom calldata and encodes back
    function decodeNEncodeExample(string calldata _name, string calldata _symbol, uint256 _decimals) external pure returns(string memory, string memory, uint256) {
        assembly {
            // Gets calldata size except selector's 4 bytes
            let cdSize := sub(calldatasize(), 4)
            // Copies calldata starting from 0x00 slot
            calldatacopy(0, 4, cdSize)

            // Cursor which points where to store encoded body
            // Depends on how many fields should be store. In this case is 3 (name, symbol, decimals)
            let cursor := mul(3, 0x20)

            // Stores name pointer
            mstore(cdSize, cursor)
            // Stores name data and accumulates the cursor based on how many bytes were used while storing the string
            cursor := add(cursor, storeAsBytes(cursor, add(cdSize, cursor)))

            // Stores symbol pointer
            mstore(add(cdSize, 0x20), cursor)
            // Stores symbol data and accumulates the cursor
            cursor := add(cursor, storeAsBytes(cursor, add(cdSize, cursor))) // store symbol data

            // Stores decimals uint
            mstore(add(cdSize, 0x40), mload(0x40)) // store decimals

            // Takes a location where the data starts (location of a size slot)
            // Takes a location where to store handled data (location of a size slot)
            // Returns how many bytes were used to store the data
            function storeAsBytes(loc, storeAt) -> _cursor {
                // Gets size of the data in bytes (following by ABI encode format)
                let size := mload(loc)
                // Store size into the first slot
                mstore(storeAt, size)
                // Gets number of fully occupied slots
                let numSlots := div(size, 0x20)
                // Not zero division remainder means there's one more slot occupied by half
                if mod(size, 0x20) {
                    numSlots := add(numSlots, 1)
                }
                // Storing starts from 0x20 because 0x00 used for storing the size
                _cursor := 0x20
                // Gets data location starting from next to the size slot
                let dataLocation := add(loc, 0x20)
                // Iterates over calculated number of slots and stores slots one by one
                for { let i := 0 } lt(i, numSlots) { i := add(i, 1) }
                {
                    mstore(
                        add(storeAt, _cursor), 
                        mload(add(dataLocation, mul(i, 0x20)))
                    )
                    _cursor := add(_cursor, 0x20)
                }
            }

            return(cdSize, cursor)
        }
    }

    function testMemoryVar() external pure returns(bytes32 a, bytes32 b, bytes32 c) {
        bytes memory foo = hex"534536266252345235";
        assembly {
            a := foo // pointer where foo starts in memory
            b := mload(0x40) // free pointer after foo
            c := mload(a) // length
        }
    }
}