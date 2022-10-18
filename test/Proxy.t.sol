// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Counter.sol";
import "../src/Deployer.sol";

using { compile } for Vm;
using { create, appendArg } for bytes;

contract ProxyTest is Test {
    address impl;
    address proxy;

    function setUp() public {
        impl = address(new Counter());

        bytes memory bc = vm.compile("huff/Proxy.huff").appendArg(impl);

        // Changes the compiled offset of the bytecode so it
        // includes the immutable variable
        // AKA adds ONE 4byte/0x20/(32-bit) data to the end of the *deployed*
        // contract address
        // Hacky, but can't seem to find another way to do it
        // https://github.com/MathisGD/huff-immutable/blob/main/test/SimpleImmutable.t.sol
        bc[1] = bytes1(0x20 + uint8(bc[1]));

        proxy = create(bc, 0);
    }

    function testProxy() public {
        Counter(proxy).increment();

        emit log_address(impl);
        // emit log_bytes(address(proxy).code);
    }
}
