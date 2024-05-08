// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {AuthCall} from "../src/AuthCall.sol";

contract AuthCallScript is Script {
    function run() public {
        vm.startBroadcast();
        AuthCall authCall = new AuthCall();
        vm.stopBroadcast();
    }
}