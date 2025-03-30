// SPDX-License-Identifier: VPL-1.0
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {Hooks} from "v4-core/src/libraries/Hooks.sol";
import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {Constants} from "../base/Constants.sol";

import {MiladyBankRouter} from "../../src/router/MiladyBankRouter.sol";
import {HookMiner} from "v4-periphery/src/utils/HookMiner.sol";

contract MiladyBankRouterScript is Script, Constants {
    function setUp() public {}

    function run() public {
        bytes memory constructorArgs = abi.encode(POOLMANAGER);
        MiladyBank bank = MiladyBank(address(0));

        vm.broadcast();
        MiladyBankRouter router = new MiladyBankRouter{salt: 0}(IPoolManager(POOLMANAGER), bank);
    }
}
