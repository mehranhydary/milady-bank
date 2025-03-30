// SPDX-License-Identifier: VPL-1.0
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {Hooks} from "v4-core/src/libraries/Hooks.sol";
import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {Constants} from "../base/Constants.sol";

import {MiladyBank} from "../../src/bank/MiladyBank.sol";
import {HookMiner} from "v4-periphery/src/utils/HookMiner.sol";

contract MiladyBankScript is Script, Constants {
    function setUp() public {}

    function run() public {
        uint160 flags = uint160(
            Hooks.BEFORE_INITIALIZE_FLAG | Hooks.AFTER_INITIALIZE_FLAG | Hooks.BEFORE_SWAP_FLAG | Hooks.AFTER_SWAP_FLAG
                | Hooks.BEFORE_ADD_LIQUIDITY_FLAG | Hooks.BEFORE_REMOVE_LIQUIDITY_FLAG
        );

        bytes memory constructorArgs = abi.encode(POOLMANAGER);

        (address hookAddress, bytes32 salt) =
            HookMiner.find(CREATE2_DEPLOYER, flags, type(MiladyBank).creationCode, constructorArgs);

        vm.broadcast();
        MiladyBank bank = new MiladyBank{salt: salt}(IPoolManager(POOLMANAGER));
        require(address(bank) == hookAddress, "MiladyBankScript: hook address mismatch");
    }
}
