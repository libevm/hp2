// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {Vm} from "forge-std/Vm.sol";

using { compile } for Vm;
using { appendArg, create } for bytes;

function compile(Vm vm, string memory path) returns (bytes memory) {
    string[] memory cmd = new string[](3);
    cmd[0] = "huffc";
    cmd[1] = "--bytecode";
    cmd[2] = path;
    return vm.ffi(cmd);
}

error DeploymentFailure(bytes bytecode);

function create(bytes memory bytecode, uint256 value) returns (address deployedAddress) {
    assembly {
        deployedAddress := create(value, add(bytecode, 0x20), mload(bytecode))
    }

    if (deployedAddress == address(0)) revert DeploymentFailure(bytecode);
}

function create2(
    bytes memory bytecode,
    uint256 value,
    bytes32 salt
) returns (address deployedAddress) {
    assembly {
        deployedAddress := create2(value, add(bytecode, 0x20), mload(bytecode), salt)
    }

    if (deployedAddress == address(0)) revert DeploymentFailure(bytecode);
}

function appendArg(bytes memory bytecode, address arg) pure returns (bytes memory) {
    return bytes.concat(bytecode, abi.encode(arg));
}

contract TryDeployer {
    address a;

    constructor(bytes memory bytecode, uint256 value) {
        a = create(bytecode, value);
    }

    function getDeployedBytecode() external view returns (bytes memory) {
        return address(a).code;
    }
}

function deployJohnsProxy(Vm vm, address impl) returns (address) {
    bytes memory bc = vm.compile("huff/MVP.huff").appendArg(impl);
    return create(bc, 0);
}

function deployProxy(Vm vm, address impl, address owner) returns (address) {
    // Get this value from script/GetOffset.s.sol
    uint256 immutableAddressOffset = 44;

    bytes memory bc = vm.compile("huff/Proxy.huff").appendArg(impl).appendArg(owner);
    bc[immutableAddressOffset] = bytes1(0x20 + uint8(bc[immutableAddressOffset]));
    return create(bc, 0);
}