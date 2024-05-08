// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {AuthCall} from "../src/AuthCall.sol";

contract AuthTest is Test {
    AuthCall internal invoker = new AuthCall();

    function setUp() public {}

    function test_MultiAuthCall() public {
        uint256 accountKey = uint256(keccak256("secret"));
        address account = vm.addr(accountKey);

        bytes32 authDigest = keccak256(
            abi.encodePacked(
                uint8(0x04),
                block.chainid,
                uint256(vm.getNonce(account)),
                uint256(uint160(address(invoker))),
                invoker.COMMIT()
            )
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(accountKey, authDigest);
        bytes memory signature = abi.encodePacked(v - 27, r, s);

        bytes memory transactions = abi.encodePacked(
            abi.encodePacked(
                uint8(0),
                address(0),
                uint256(1 gwei), // value
                uint256(0), // data length
                "" // data
            ),
            abi.encodePacked(
                uint8(0),
                address(0),
                uint256(2 gwei), // value
                uint256(0), // data length
                "" // data
            )
        );

        vm.deal(account, 1 ether);
        assertEq(account.balance, 1 ether);

        invoker.multiAuthCall(account, signature, transactions);

        assertEq(account.balance, 1 ether - 3 gwei);
    }

    function test_MultiSendCompatibility() public {
        uint256 accountKey = uint256(keccak256("secret"));
        address account = vm.addr(accountKey);

        bytes32 authDigest = keccak256(
            abi.encodePacked(
                uint8(0x04),
                block.chainid,
                uint256(vm.getNonce(account)),
                uint256(uint160(address(invoker))),
                invoker.COMMIT()
            )
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(accountKey, authDigest);
        bytes memory signature = abi.encodePacked(v - 27, r, s);

        bytes memory transactions = abi.encodePacked(
            // auth encoded in transactions
            abi.encodePacked(
                uint8(0),
                account,
                uint256(0), // ignored
                signature.length,
                signature
            ),
            abi.encodePacked(
                uint8(0),
                address(0),
                uint256(1 gwei), // value
                uint256(0), // data length
                "" // data
            ),
            abi.encodePacked(
                uint8(0),
                address(0),
                uint256(2 gwei), // value
                uint256(0), // data length
                "" // data
            )
        );

        vm.deal(account, 1 ether);
        assertEq(account.balance, 1 ether);

        invoker.multiSend(transactions);

        assertEq(account.balance, 1 ether - 3 gwei);
    }
}
