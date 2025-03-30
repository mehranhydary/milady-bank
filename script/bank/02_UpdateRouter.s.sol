// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {MiladyBank} from "../../src/bank/MiladyBank.sol";

contract UpdateRouterScript is Script {
    function run() external {
        // Load deployer private key from environment
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // Get bank contract address from environment
        // NOTE: Update here
        address bankAddress = vm.envAddress("MILADY_BANK_ADDRESS");

        // Get router address from environment
        // NOTE: Update here
        address routerAddress = vm.envAddress("ROUTER_ADDRESS");

        // Start broadcast
        vm.startBroadcast(deployerPrivateKey);

        // Update router
        MiladyBank bank = MiladyBank(bankAddress);
        bank.setRouter(routerAddress);

        vm.stopBroadcast();
    }
}
