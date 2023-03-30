// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract Memory1 {

    struct Point {
        uint256 x;
        uint256 y;
    }

    event MemoryPointer(bytes32);
    event MemoryPointerMsize(bytes32, bytes32);

    function mstore8() external pure {
        assembly {
            // 0x0700000000000000000000000000000000000000000000000000000000000000
            mstore8(0x00, 7) // write 1 byte to the beginning of a word
            // 0x0000000000000000000000000000000000000000000000000000000000000007
            mstore(0x20, 7) // write 32 bytes to the entire word
        }
    }

    function memPointer() external {
        bytes32 x40;
        bytes32 _msize;
        assembly {
            // 0x0000000000000000000000000000000000000000000000000000000000000080
            // it means the closest empty slot after 0x80, which you can write in, is the value above
            // so 0x40-0x60 word stores the free memory pointer, that points where you can store something safely
            x40 := mload(0x40) // load value from [0x40; 0x40 + 0x20] word => 0x...80
            // the largest accessed memory index
            // 0x60 because of the zero slot between 0x40-0x60 and 0x80-0xa0
            _msize := msize() // 0x60
        }
        emit MemoryPointerMsize(x40, _msize); 
        Point memory p = Point({x: 5, y: 10});
        assembly {
            // 0x00000000000000000000000000000000000000000000000000000000000000c0
            // after storing Point p to memory, 0x80-0xa0 and 0xa0-0xc0 were used, so the next free slot is 0xc0-0xe0
            x40 := mload(0x40) // 0xc0
            _msize := msize() // 0xc0
        }
        emit MemoryPointerMsize(x40, _msize);

        assembly {
            pop(mload(0xff))
            x40 := mload(0x40) // 0xc0
            _msize := msize() // 0x120, because 0xff was accessed, so 0xff + 0x20 + remaining byte (0xff % 0x20 != 0, but slot is 32 byte length) = 0x120
        }
        emit MemoryPointerMsize(x40, _msize);
    }

    function getPoint() external pure returns(uint256 x, uint256 y) {
        bytes32 x40;
        assembly {
            x40 := mload(0x40)
        }
        Point memory p = Point({x: 5, y: 10});
        assembly {
            x40 := mload(0x40)
        }

        assembly {
            x := mload(0x80)
            y := mload(add(0x80, 0x32))
        }
    }

    function fixedArray() external pure returns(uint256 first, uint256 second) {
        bytes32 x40;
        assembly {
            x40 := mload(0x40) // 0x80
        }
        uint256[2] memory arr = [uint256(5), uint256(6)];
        assembly {
            x40 := mload(0x40) // 0xc0
        }
        assembly {
            first := mload(0x80)
            second := mload(add(0x80, 0x20))
        }
    }

    function abiEncode() external pure returns(uint256 length, uint256 first, uint256 second) {
        bytes32 x40;
        assembly {
            x40 := mload(0x40) // 0x80
        }
        bytes memory encoded = abi.encode(uint256(5), uint128(6)); // no matter uint256 or uintN is inside, one value - one 32 bytes slot
        assembly {
            x40 := mload(0x40) // 0xe0 (one slot is for length)
        }
        assembly {
            length := mload(0x80) // 64 (2 slots of 32 bytes)
            first := mload(add(0x80, 0x20))
            second := mload(add(0x80, add(0x20, 0x20)))
        }
    }

    function abiEncodePacked() external pure returns(uint256 length, bytes2 values) {
        bytes32 x40;
        assembly {
            x40 := mload(0x40) // 0x80
        }
        bytes memory encoded = abi.encodePacked(uint8(5), uint8(6));
        assembly {
            // 0x80-0xa0 = length in bytes (uint256 x uint256 = 64)
            // value allocation size depends on what type has been packed
            // 0xe0, when two slots allocated (256x128)
            // 0xc0, one packed into one slot (128x128)
            // 0xb0, when packed into a half of slot (64x64)
            // 0xa2, when uint8 x uint8
            x40 := mload(0x40) 
        }
        assembly {
            length := mload(0x80)
            values := mload(add(0x80, 0x20))
        }
        // to check where is this located after packing
        Point memory p = Point({x: 10, y: 20});
    }
    
    function garbageCheck() external pure returns(uint256 x1, uint256 y1, uint256 x2, uint256 y2) {
        Point memory p = Point({x: 10, y: 20});
        // rewriting variable
        p = Point({x: 30, y: 40});
        assembly {
            x1 := mload(0x80) // 10
            y1 := mload(add(0x80, 0x20)) // 20
            x2 := mload(add(0x80, add(0x20, 0x20))) // 30
            y2 := mload(add(0x80, add(0x20, add(0x20, 0x20)))) // 40
        }
        // even if a variable is overridden, memory is not freed
    }

    event Debug(bytes32, bytes32, bytes32, bytes32);
    function dynamicArray(uint256[] memory arr) external {
        bytes32 location;
        bytes32 len;
        bytes32 first;
        bytes32 second;

        assembly {
            location := arr // 0x80: arr is just a location of the slot which contains length of the passed array
            len := mload(arr) // 0x0000000000000000000000000000000000000000000000000000000000000003
            first := mload(add(arr, 0x20)) // 0x0000000000000000000000000000000000000000000000000000000000000001
            second := mload(add(arr, 0x40)) // 0x0000000000000000000000000000000000000000000000000000000000000002
            // the same structure is for any type of the arr (uint8 etc)
        }

        emit Debug(location, len, first, second);
    }

}