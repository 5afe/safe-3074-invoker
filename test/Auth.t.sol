// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";

contract Invoker {
    function commit() public view returns (bytes32 value) {
        assembly ("memory-safe") {
            value := extcodehash(address())
        }
    }

    function burnForMe(uint256 amount, address authority, bytes calldata signature) external {
        bytes memory authData = abi.encodePacked(signature, commit());

        bool success;
        assembly ("memory-safe") {
            success := auth(authority, add(authData, 0x20), mload(authData))
        }
        require(success, "auth failed");

        assembly ("memory-safe") {
            if iszero(authcall(gas(), 0, amount, 0, 0, 0, 0)) {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }
        }
    }
}

contract AuthTest is Test {
    Invoker internal invoker = new Invoker();

    function setUp() public {}

    function test_Increment() public {
        uint256 accountKey = uint256(keccak256("secret"));
        address account = vm.addr(accountKey);

        bytes32 authDigest = keccak256(
            abi.encodePacked(
                uint8(0x04),
                block.chainid,
                uint256(vm.getNonce(account)),
                uint256(uint160(address(invoker))),
                invoker.commit()
            )
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(accountKey, authDigest);
        bytes memory signature = abi.encodePacked(v - 27, r, s);

        vm.deal(account, 1 ether);
        assertEq(account.balance, 1 ether);

        invoker.burnForMe(1 gwei, account, signature);

        assertEq(account.balance, 1 ether - 1 gwei);
    }
}
