// SPDX-License-Identifier: VPL-1.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {Hooks} from "v4-core/src/libraries/Hooks.sol";

import {Fixtures} from "./utils/Fixtures.sol";

contract MiladyBankTest is Test, Fixtures {
    function setUp() public {
        // Deploy the hook to an address with the correct flags
        address flags = address(
            uint160(
                Hooks.BEFORE_INITIALIZE_FLAG | Hooks.AFTER_INITIALIZE_FLAG | Hooks.BEFORE_SWAP_FLAG
                    | Hooks.AFTER_SWAP_FLAG | Hooks.BEFORE_ADD_LIQUIDITY_FLAG | Hooks.BEFORE_REMOVE_LIQUIDITY_FLAG
            ) ^ (0x4444 << 144) // Namespace the hook to avoid collisions
        );
    }
}
