// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Counter.sol";
import "../src/Deployer.sol";
import "../src/IProxy.sol";

using { create, appendArg } for bytes;

contract ProxyTest is Test {
    address impl;

    function setUp() public {
        impl = address(new Counter());
    }

    function testProxyBasics() public {
        address proxy = deployProxy(vm, impl, address(this));
        uint256 _before = Counter(proxy).number();
        Counter(proxy).increment();
        uint256 _after = Counter(proxy).number();
        assertGt(_after, _before);
        IProxy(proxy).destroy();
    }

    function testProxyOwnerDestroy() public {
        address proxy = deployProxy(vm, impl, impl);

        uint256 _before = Counter(proxy).number();
        Counter(proxy).increment();
        uint256 _after = Counter(proxy).number();
        assertGt(_after, _before);

        try IProxy(proxy).destroy() {
            // We shouldn't be able to destroy the proxy
            fail();
        } catch {}
    }
}
