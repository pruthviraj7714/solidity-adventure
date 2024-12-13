// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {MessageStorage} from "../src/MessageStorage.sol";

contract MessageStorageScript is Script {
    MessageStorage public messageStorage;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        messageStorage = new MessageStorage();

        vm.stopBroadcast();
    }
}
