// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/console.sol";
import "forge-std/Test.sol";
import "../src/Counter.sol";
import "../src/Deployer.sol";

using { compile } for Vm;
using { create, appendArg } for bytes;

contract GasProfiler is Script {
    address johnsProxy;
    address mySuperiorProxy;

    address impl;

    function setUp() public {
        impl = address(new Counter());
        
        johnsProxy = deployJohnsProxy(vm, impl);
        mySuperiorProxy = deployProxy(vm, impl, address(this));
    }

    function run() public {
        uint256 gasBefore;
        uint256 johnGasUsed;
        uint256 myGasUsed;

        gasBefore = gasleft();
        Counter(johnsProxy).increment();
        johnGasUsed = gasBefore - gasleft();

        gasBefore = gasleft();
        Counter(mySuperiorProxy).increment();
        myGasUsed = gasBefore - gasleft();

        console.log("Counter.increment gasProfiling");
        console.log("==============================");

        console.log("Jtriley's proxy gas used: ");
        console.log(johnGasUsed);
        console.log("====");
        console.log("HP2 proxy gas used: ");
        console.log(myGasUsed);
    }
}
