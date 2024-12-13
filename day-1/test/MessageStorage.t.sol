// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import { MessageStorage } from "../src/MessageStorage.sol";

contract MessageStorageTest is Test {
    MessageStorage public m;

    function setUp() public {
        m = new MessageStorage();
    }

    function testSetMessage(string memory _msg) public {
        m.setMessage(_msg);
        assertEq(m.message(), _msg, "ok");
    }

}
