// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/Deployer.sol";
import "../src/IProxy.sol";

using { compile } for Vm;
using { create, appendArg } for bytes;

contract GetOffset is Script {
    address impl;

    function setUp() public {
        impl = address(this);
    }

    function run() public {
        // Brute force getting the offset
        bytes memory bc = vm.compile("huff/Proxy.huff").appendArg(impl).appendArg(address(this));
        bytes1 tempb;

        for (uint256 i = 0; i < bc.length; i++) {
            tempb = bc[i];

            // overflow
            if (bc[i] > 0xe0) {
                continue;
            }

            // Changes the compiled offset of the bytecode so it
            // includes the immutable variable
            // AKA adds ONE 4byte/0x20/(32-bit) data to the end of the *deployed*
            // contract address
            // Hacky, but can't seem to find another way to do it
            // https://github.com/MathisGD/huff-immutable/blob/main/test/SimpleImmutable.t.sol
            bc[i] = bytes1(0x20 + uint8(bc[i]));

            // Check for each deployment, which one will return the immutable address
            try new TryDeployer(bc, 0) returns (TryDeployer td) {
                bytes memory bytecode = td.getDeployedBytecode();

                address extractedAddress;
                uint256 loc = bytecode.length - 20;
                assembly {
                    extractedAddress := mload(add(add(bytecode, 20), loc))
                }

                if (extractedAddress == impl) {
                    console.log("Deploy with offset");
                    console.log(i);
                    break;
                    // emit log_uint(i);
                }
            } catch {}

            // reassign
            bc[i] = tempb;
        }
    }
}
