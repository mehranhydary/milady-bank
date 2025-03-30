// SPDX-License-Identifier: VPL-1.0
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Currency, CurrencyLibrary} from "v4-core/src/types/Currency.sol";

library TokenUtils {
    using CurrencyLibrary for Currency;

    function transferFromUser(Currency currency, address user, address recipient, int256 amount)
        internal
        returns (uint256)
    {
        require(amount > 0, "Amount must be positive");
        uint256 uAmount = uint256(amount);
        IERC20(Currency.unwrap(currency)).transferFrom(user, recipient, uAmount);
        return uAmount;
    }

    function approve(Currency currency, address spender, uint256 amount) internal {
        IERC20(Currency.unwrap(currency)).approve(spender, amount);
    }

    function transfer(Currency currency, address recipient, uint256 amount) internal {
        if (amount > 0) {
            currency.transfer(recipient, amount);
        }
    }
}
