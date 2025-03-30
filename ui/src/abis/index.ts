export const MILADY_BANK_ABI = [
	{
		type: 'constructor',
		inputs: [
			{
				name: '_poolManager',
				type: 'address',
				internalType: 'contract IPoolManager',
			},
		],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'LIQUIDATION_BONUS',
		inputs: [],
		outputs: [{ name: '', type: 'uint256', internalType: 'uint256' }],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'LIQUIDATION_THRESHOLD',
		inputs: [],
		outputs: [{ name: '', type: 'uint256', internalType: 'uint256' }],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'MAX_BORROW_PER_WINDOW',
		inputs: [],
		outputs: [{ name: '', type: 'uint256', internalType: 'uint256' }],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'MIN_HOLD_TIME',
		inputs: [],
		outputs: [{ name: '', type: 'uint256', internalType: 'uint256' }],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'RATE_LIMIT_WINDOW',
		inputs: [],
		outputs: [{ name: '', type: 'uint256', internalType: 'uint256' }],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'STALENESS_PERIOD',
		inputs: [],
		outputs: [{ name: '', type: 'uint32', internalType: 'uint32' }],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'TWAP_PERIOD',
		inputs: [],
		outputs: [{ name: '', type: 'uint32', internalType: 'uint32' }],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'afterAddLiquidity',
		inputs: [
			{ name: 'sender', type: 'address', internalType: 'address' },
			{
				name: 'key',
				type: 'tuple',
				internalType: 'struct PoolKey',
				components: [
					{
						name: 'currency0',
						type: 'address',
						internalType: 'Currency',
					},
					{
						name: 'currency1',
						type: 'address',
						internalType: 'Currency',
					},
					{ name: 'fee', type: 'uint24', internalType: 'uint24' },
					{
						name: 'tickSpacing',
						type: 'int24',
						internalType: 'int24',
					},
					{
						name: 'hooks',
						type: 'address',
						internalType: 'contract IHooks',
					},
				],
			},
			{
				name: 'params',
				type: 'tuple',
				internalType: 'struct IPoolManager.ModifyLiquidityParams',
				components: [
					{ name: 'tickLower', type: 'int24', internalType: 'int24' },
					{ name: 'tickUpper', type: 'int24', internalType: 'int24' },
					{
						name: 'liquidityDelta',
						type: 'int256',
						internalType: 'int256',
					},
					{ name: 'salt', type: 'bytes32', internalType: 'bytes32' },
				],
			},
			{ name: 'delta', type: 'int256', internalType: 'BalanceDelta' },
			{
				name: 'feesAccrued',
				type: 'int256',
				internalType: 'BalanceDelta',
			},
			{ name: 'hookData', type: 'bytes', internalType: 'bytes' },
		],
		outputs: [
			{ name: '', type: 'bytes4', internalType: 'bytes4' },
			{ name: '', type: 'int256', internalType: 'BalanceDelta' },
		],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'afterDonate',
		inputs: [
			{ name: 'sender', type: 'address', internalType: 'address' },
			{
				name: 'key',
				type: 'tuple',
				internalType: 'struct PoolKey',
				components: [
					{
						name: 'currency0',
						type: 'address',
						internalType: 'Currency',
					},
					{
						name: 'currency1',
						type: 'address',
						internalType: 'Currency',
					},
					{ name: 'fee', type: 'uint24', internalType: 'uint24' },
					{
						name: 'tickSpacing',
						type: 'int24',
						internalType: 'int24',
					},
					{
						name: 'hooks',
						type: 'address',
						internalType: 'contract IHooks',
					},
				],
			},
			{ name: 'amount0', type: 'uint256', internalType: 'uint256' },
			{ name: 'amount1', type: 'uint256', internalType: 'uint256' },
			{ name: 'hookData', type: 'bytes', internalType: 'bytes' },
		],
		outputs: [{ name: '', type: 'bytes4', internalType: 'bytes4' }],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'afterInitialize',
		inputs: [
			{ name: 'sender', type: 'address', internalType: 'address' },
			{
				name: 'key',
				type: 'tuple',
				internalType: 'struct PoolKey',
				components: [
					{
						name: 'currency0',
						type: 'address',
						internalType: 'Currency',
					},
					{
						name: 'currency1',
						type: 'address',
						internalType: 'Currency',
					},
					{ name: 'fee', type: 'uint24', internalType: 'uint24' },
					{
						name: 'tickSpacing',
						type: 'int24',
						internalType: 'int24',
					},
					{
						name: 'hooks',
						type: 'address',
						internalType: 'contract IHooks',
					},
				],
			},
			{ name: 'sqrtPriceX96', type: 'uint160', internalType: 'uint160' },
			{ name: 'tick', type: 'int24', internalType: 'int24' },
		],
		outputs: [{ name: '', type: 'bytes4', internalType: 'bytes4' }],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'afterRemoveLiquidity',
		inputs: [
			{ name: 'sender', type: 'address', internalType: 'address' },
			{
				name: 'key',
				type: 'tuple',
				internalType: 'struct PoolKey',
				components: [
					{
						name: 'currency0',
						type: 'address',
						internalType: 'Currency',
					},
					{
						name: 'currency1',
						type: 'address',
						internalType: 'Currency',
					},
					{ name: 'fee', type: 'uint24', internalType: 'uint24' },
					{
						name: 'tickSpacing',
						type: 'int24',
						internalType: 'int24',
					},
					{
						name: 'hooks',
						type: 'address',
						internalType: 'contract IHooks',
					},
				],
			},
			{
				name: 'params',
				type: 'tuple',
				internalType: 'struct IPoolManager.ModifyLiquidityParams',
				components: [
					{ name: 'tickLower', type: 'int24', internalType: 'int24' },
					{ name: 'tickUpper', type: 'int24', internalType: 'int24' },
					{
						name: 'liquidityDelta',
						type: 'int256',
						internalType: 'int256',
					},
					{ name: 'salt', type: 'bytes32', internalType: 'bytes32' },
				],
			},
			{ name: 'delta', type: 'int256', internalType: 'BalanceDelta' },
			{
				name: 'feesAccrued',
				type: 'int256',
				internalType: 'BalanceDelta',
			},
			{ name: 'hookData', type: 'bytes', internalType: 'bytes' },
		],
		outputs: [
			{ name: '', type: 'bytes4', internalType: 'bytes4' },
			{ name: '', type: 'int256', internalType: 'BalanceDelta' },
		],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'afterSwap',
		inputs: [
			{ name: 'sender', type: 'address', internalType: 'address' },
			{
				name: 'key',
				type: 'tuple',
				internalType: 'struct PoolKey',
				components: [
					{
						name: 'currency0',
						type: 'address',
						internalType: 'Currency',
					},
					{
						name: 'currency1',
						type: 'address',
						internalType: 'Currency',
					},
					{ name: 'fee', type: 'uint24', internalType: 'uint24' },
					{
						name: 'tickSpacing',
						type: 'int24',
						internalType: 'int24',
					},
					{
						name: 'hooks',
						type: 'address',
						internalType: 'contract IHooks',
					},
				],
			},
			{
				name: 'params',
				type: 'tuple',
				internalType: 'struct IPoolManager.SwapParams',
				components: [
					{ name: 'zeroForOne', type: 'bool', internalType: 'bool' },
					{
						name: 'amountSpecified',
						type: 'int256',
						internalType: 'int256',
					},
					{
						name: 'sqrtPriceLimitX96',
						type: 'uint160',
						internalType: 'uint160',
					},
				],
			},
			{ name: 'delta', type: 'int256', internalType: 'BalanceDelta' },
			{ name: 'hookData', type: 'bytes', internalType: 'bytes' },
		],
		outputs: [
			{ name: '', type: 'bytes4', internalType: 'bytes4' },
			{ name: '', type: 'int128', internalType: 'int128' },
		],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'beforeAddLiquidity',
		inputs: [
			{ name: 'sender', type: 'address', internalType: 'address' },
			{
				name: 'key',
				type: 'tuple',
				internalType: 'struct PoolKey',
				components: [
					{
						name: 'currency0',
						type: 'address',
						internalType: 'Currency',
					},
					{
						name: 'currency1',
						type: 'address',
						internalType: 'Currency',
					},
					{ name: 'fee', type: 'uint24', internalType: 'uint24' },
					{
						name: 'tickSpacing',
						type: 'int24',
						internalType: 'int24',
					},
					{
						name: 'hooks',
						type: 'address',
						internalType: 'contract IHooks',
					},
				],
			},
			{
				name: 'params',
				type: 'tuple',
				internalType: 'struct IPoolManager.ModifyLiquidityParams',
				components: [
					{ name: 'tickLower', type: 'int24', internalType: 'int24' },
					{ name: 'tickUpper', type: 'int24', internalType: 'int24' },
					{
						name: 'liquidityDelta',
						type: 'int256',
						internalType: 'int256',
					},
					{ name: 'salt', type: 'bytes32', internalType: 'bytes32' },
				],
			},
			{ name: 'hookData', type: 'bytes', internalType: 'bytes' },
		],
		outputs: [{ name: '', type: 'bytes4', internalType: 'bytes4' }],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'beforeDonate',
		inputs: [
			{ name: 'sender', type: 'address', internalType: 'address' },
			{
				name: 'key',
				type: 'tuple',
				internalType: 'struct PoolKey',
				components: [
					{
						name: 'currency0',
						type: 'address',
						internalType: 'Currency',
					},
					{
						name: 'currency1',
						type: 'address',
						internalType: 'Currency',
					},
					{ name: 'fee', type: 'uint24', internalType: 'uint24' },
					{
						name: 'tickSpacing',
						type: 'int24',
						internalType: 'int24',
					},
					{
						name: 'hooks',
						type: 'address',
						internalType: 'contract IHooks',
					},
				],
			},
			{ name: 'amount0', type: 'uint256', internalType: 'uint256' },
			{ name: 'amount1', type: 'uint256', internalType: 'uint256' },
			{ name: 'hookData', type: 'bytes', internalType: 'bytes' },
		],
		outputs: [{ name: '', type: 'bytes4', internalType: 'bytes4' }],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'beforeInitialize',
		inputs: [
			{ name: 'sender', type: 'address', internalType: 'address' },
			{
				name: 'key',
				type: 'tuple',
				internalType: 'struct PoolKey',
				components: [
					{
						name: 'currency0',
						type: 'address',
						internalType: 'Currency',
					},
					{
						name: 'currency1',
						type: 'address',
						internalType: 'Currency',
					},
					{ name: 'fee', type: 'uint24', internalType: 'uint24' },
					{
						name: 'tickSpacing',
						type: 'int24',
						internalType: 'int24',
					},
					{
						name: 'hooks',
						type: 'address',
						internalType: 'contract IHooks',
					},
				],
			},
			{ name: 'sqrtPriceX96', type: 'uint160', internalType: 'uint160' },
		],
		outputs: [{ name: '', type: 'bytes4', internalType: 'bytes4' }],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'beforeRemoveLiquidity',
		inputs: [
			{ name: 'sender', type: 'address', internalType: 'address' },
			{
				name: 'key',
				type: 'tuple',
				internalType: 'struct PoolKey',
				components: [
					{
						name: 'currency0',
						type: 'address',
						internalType: 'Currency',
					},
					{
						name: 'currency1',
						type: 'address',
						internalType: 'Currency',
					},
					{ name: 'fee', type: 'uint24', internalType: 'uint24' },
					{
						name: 'tickSpacing',
						type: 'int24',
						internalType: 'int24',
					},
					{
						name: 'hooks',
						type: 'address',
						internalType: 'contract IHooks',
					},
				],
			},
			{
				name: 'params',
				type: 'tuple',
				internalType: 'struct IPoolManager.ModifyLiquidityParams',
				components: [
					{ name: 'tickLower', type: 'int24', internalType: 'int24' },
					{ name: 'tickUpper', type: 'int24', internalType: 'int24' },
					{
						name: 'liquidityDelta',
						type: 'int256',
						internalType: 'int256',
					},
					{ name: 'salt', type: 'bytes32', internalType: 'bytes32' },
				],
			},
			{ name: 'hookData', type: 'bytes', internalType: 'bytes' },
		],
		outputs: [{ name: '', type: 'bytes4', internalType: 'bytes4' }],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'beforeSwap',
		inputs: [
			{ name: 'sender', type: 'address', internalType: 'address' },
			{
				name: 'key',
				type: 'tuple',
				internalType: 'struct PoolKey',
				components: [
					{
						name: 'currency0',
						type: 'address',
						internalType: 'Currency',
					},
					{
						name: 'currency1',
						type: 'address',
						internalType: 'Currency',
					},
					{ name: 'fee', type: 'uint24', internalType: 'uint24' },
					{
						name: 'tickSpacing',
						type: 'int24',
						internalType: 'int24',
					},
					{
						name: 'hooks',
						type: 'address',
						internalType: 'contract IHooks',
					},
				],
			},
			{
				name: 'params',
				type: 'tuple',
				internalType: 'struct IPoolManager.SwapParams',
				components: [
					{ name: 'zeroForOne', type: 'bool', internalType: 'bool' },
					{
						name: 'amountSpecified',
						type: 'int256',
						internalType: 'int256',
					},
					{
						name: 'sqrtPriceLimitX96',
						type: 'uint160',
						internalType: 'uint160',
					},
				],
			},
			{ name: 'hookData', type: 'bytes', internalType: 'bytes' },
		],
		outputs: [
			{ name: '', type: 'bytes4', internalType: 'bytes4' },
			{ name: '', type: 'int256', internalType: 'BeforeSwapDelta' },
			{ name: '', type: 'uint24', internalType: 'uint24' },
		],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'checkHealth',
		inputs: [
			{ name: 'user', type: 'address', internalType: 'address' },
			{
				name: 'key',
				type: 'tuple',
				internalType: 'struct PoolKey',
				components: [
					{
						name: 'currency0',
						type: 'address',
						internalType: 'Currency',
					},
					{
						name: 'currency1',
						type: 'address',
						internalType: 'Currency',
					},
					{ name: 'fee', type: 'uint24', internalType: 'uint24' },
					{
						name: 'tickSpacing',
						type: 'int24',
						internalType: 'int24',
					},
					{
						name: 'hooks',
						type: 'address',
						internalType: 'contract IHooks',
					},
				],
			},
		],
		outputs: [
			{ name: 'healthFactor', type: 'uint256', internalType: 'uint256' },
		],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'deposit',
		inputs: [
			{
				name: 'key',
				type: 'tuple',
				internalType: 'struct PoolKey',
				components: [
					{
						name: 'currency0',
						type: 'address',
						internalType: 'Currency',
					},
					{
						name: 'currency1',
						type: 'address',
						internalType: 'Currency',
					},
					{ name: 'fee', type: 'uint24', internalType: 'uint24' },
					{
						name: 'tickSpacing',
						type: 'int24',
						internalType: 'int24',
					},
					{
						name: 'hooks',
						type: 'address',
						internalType: 'contract IHooks',
					},
				],
			},
			{ name: 'amount', type: 'int256', internalType: 'int256' },
		],
		outputs: [],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'getHookPermissions',
		inputs: [],
		outputs: [
			{
				name: '',
				type: 'tuple',
				internalType: 'struct Hooks.Permissions',
				components: [
					{
						name: 'beforeInitialize',
						type: 'bool',
						internalType: 'bool',
					},
					{
						name: 'afterInitialize',
						type: 'bool',
						internalType: 'bool',
					},
					{
						name: 'beforeAddLiquidity',
						type: 'bool',
						internalType: 'bool',
					},
					{
						name: 'afterAddLiquidity',
						type: 'bool',
						internalType: 'bool',
					},
					{
						name: 'beforeRemoveLiquidity',
						type: 'bool',
						internalType: 'bool',
					},
					{
						name: 'afterRemoveLiquidity',
						type: 'bool',
						internalType: 'bool',
					},
					{ name: 'beforeSwap', type: 'bool', internalType: 'bool' },
					{ name: 'afterSwap', type: 'bool', internalType: 'bool' },
					{
						name: 'beforeDonate',
						type: 'bool',
						internalType: 'bool',
					},
					{ name: 'afterDonate', type: 'bool', internalType: 'bool' },
					{
						name: 'beforeSwapReturnDelta',
						type: 'bool',
						internalType: 'bool',
					},
					{
						name: 'afterSwapReturnDelta',
						type: 'bool',
						internalType: 'bool',
					},
					{
						name: 'afterAddLiquidityReturnDelta',
						type: 'bool',
						internalType: 'bool',
					},
					{
						name: 'afterRemoveLiquidityReturnDelta',
						type: 'bool',
						internalType: 'bool',
					},
				],
			},
		],
		stateMutability: 'pure',
	},
	{
		type: 'function',
		name: 'getLendingPool',
		inputs: [
			{
				name: 'key',
				type: 'tuple',
				internalType: 'struct PoolKey',
				components: [
					{
						name: 'currency0',
						type: 'address',
						internalType: 'Currency',
					},
					{
						name: 'currency1',
						type: 'address',
						internalType: 'Currency',
					},
					{ name: 'fee', type: 'uint24', internalType: 'uint24' },
					{
						name: 'tickSpacing',
						type: 'int24',
						internalType: 'int24',
					},
					{
						name: 'hooks',
						type: 'address',
						internalType: 'contract IHooks',
					},
				],
			},
		],
		outputs: [
			{ name: 'totalDeposits', type: 'int256', internalType: 'int256' },
			{ name: 'totalBorrows', type: 'int256', internalType: 'int256' },
			{ name: 'currentRate', type: 'int256', internalType: 'int256' },
			{ name: 'utilization', type: 'int256', internalType: 'int256' },
		],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'getPoolState',
		inputs: [
			{
				name: 'key',
				type: 'tuple',
				internalType: 'struct PoolKey',
				components: [
					{
						name: 'currency0',
						type: 'address',
						internalType: 'Currency',
					},
					{
						name: 'currency1',
						type: 'address',
						internalType: 'Currency',
					},
					{ name: 'fee', type: 'uint24', internalType: 'uint24' },
					{
						name: 'tickSpacing',
						type: 'int24',
						internalType: 'int24',
					},
					{
						name: 'hooks',
						type: 'address',
						internalType: 'contract IHooks',
					},
				],
			},
		],
		outputs: [
			{ name: 'totalDeposits', type: 'int256', internalType: 'int256' },
			{ name: 'totalBorrows', type: 'int256', internalType: 'int256' },
			{ name: 'currentRate', type: 'int256', internalType: 'int256' },
			{ name: 'utilization', type: 'int256', internalType: 'int256' },
		],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'getPrice',
		inputs: [
			{
				name: 'key',
				type: 'tuple',
				internalType: 'struct PoolKey',
				components: [
					{
						name: 'currency0',
						type: 'address',
						internalType: 'Currency',
					},
					{
						name: 'currency1',
						type: 'address',
						internalType: 'Currency',
					},
					{ name: 'fee', type: 'uint24', internalType: 'uint24' },
					{
						name: 'tickSpacing',
						type: 'int24',
						internalType: 'int24',
					},
					{
						name: 'hooks',
						type: 'address',
						internalType: 'contract IHooks',
					},
				],
			},
		],
		outputs: [{ name: '', type: 'uint256', internalType: 'uint256' }],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'getUserPosition',
		inputs: [
			{
				name: 'key',
				type: 'tuple',
				internalType: 'struct PoolKey',
				components: [
					{
						name: 'currency0',
						type: 'address',
						internalType: 'Currency',
					},
					{
						name: 'currency1',
						type: 'address',
						internalType: 'Currency',
					},
					{ name: 'fee', type: 'uint24', internalType: 'uint24' },
					{
						name: 'tickSpacing',
						type: 'int24',
						internalType: 'int24',
					},
					{
						name: 'hooks',
						type: 'address',
						internalType: 'contract IHooks',
					},
				],
			},
			{ name: 'user', type: 'address', internalType: 'address' },
		],
		outputs: [
			{ name: 'deposits', type: 'int256', internalType: 'int256' },
			{ name: 'borrows', type: 'int256', internalType: 'int256' },
			{
				name: 'lastBorrowTime',
				type: 'uint256',
				internalType: 'uint256',
			},
			{
				name: 'borrowedInWindow',
				type: 'uint256',
				internalType: 'uint256',
			},
		],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'isStale',
		inputs: [
			{
				name: 'key',
				type: 'tuple',
				internalType: 'struct PoolKey',
				components: [
					{
						name: 'currency0',
						type: 'address',
						internalType: 'Currency',
					},
					{
						name: 'currency1',
						type: 'address',
						internalType: 'Currency',
					},
					{ name: 'fee', type: 'uint24', internalType: 'uint24' },
					{
						name: 'tickSpacing',
						type: 'int24',
						internalType: 'int24',
					},
					{
						name: 'hooks',
						type: 'address',
						internalType: 'contract IHooks',
					},
				],
			},
		],
		outputs: [{ name: '', type: 'bool', internalType: 'bool' }],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'lendingPools',
		inputs: [{ name: '', type: 'bytes32', internalType: 'PoolId' }],
		outputs: [
			{ name: 'totalDeposits', type: 'int256', internalType: 'int256' },
			{ name: 'totalBorrows', type: 'int256', internalType: 'int256' },
			{
				name: 'lastInterestRate',
				type: 'int256',
				internalType: 'int256',
			},
			{
				name: 'lastUpdateTimestamp',
				type: 'uint256',
				internalType: 'uint256',
			},
		],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'liquidate',
		inputs: [
			{
				name: 'key',
				type: 'tuple',
				internalType: 'struct PoolKey',
				components: [
					{
						name: 'currency0',
						type: 'address',
						internalType: 'Currency',
					},
					{
						name: 'currency1',
						type: 'address',
						internalType: 'Currency',
					},
					{ name: 'fee', type: 'uint24', internalType: 'uint24' },
					{
						name: 'tickSpacing',
						type: 'int24',
						internalType: 'int24',
					},
					{
						name: 'hooks',
						type: 'address',
						internalType: 'contract IHooks',
					},
				],
			},
			{ name: 'user', type: 'address', internalType: 'address' },
			{ name: 'debtAmount', type: 'uint256', internalType: 'uint256' },
		],
		outputs: [],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'observations',
		inputs: [
			{ name: '', type: 'bytes32', internalType: 'bytes32' },
			{ name: '', type: 'uint256', internalType: 'uint256' },
		],
		outputs: [
			{ name: 'blockTimestamp', type: 'uint32', internalType: 'uint32' },
			{ name: 'prevTick', type: 'int24', internalType: 'int24' },
			{ name: 'tickCumulative', type: 'int48', internalType: 'int48' },
			{
				name: 'secondsPerLiquidityCumulativeX128',
				type: 'uint144',
				internalType: 'uint144',
			},
			{ name: 'initialized', type: 'bool', internalType: 'bool' },
		],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'owner',
		inputs: [],
		outputs: [{ name: '', type: 'address', internalType: 'address' }],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'pause',
		inputs: [],
		outputs: [],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'paused',
		inputs: [],
		outputs: [{ name: '', type: 'bool', internalType: 'bool' }],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'poolManager',
		inputs: [],
		outputs: [
			{
				name: '',
				type: 'address',
				internalType: 'contract IPoolManager',
			},
		],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'router',
		inputs: [],
		outputs: [{ name: '', type: 'address', internalType: 'address' }],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'setRouter',
		inputs: [{ name: '_router', type: 'address', internalType: 'address' }],
		outputs: [],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'states',
		inputs: [{ name: '', type: 'bytes32', internalType: 'bytes32' }],
		outputs: [
			{ name: 'index', type: 'uint16', internalType: 'uint16' },
			{ name: 'cardinality', type: 'uint16', internalType: 'uint16' },
			{ name: 'cardinalityNext', type: 'uint16', internalType: 'uint16' },
		],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'transferOwnership',
		inputs: [
			{ name: 'newOwner', type: 'address', internalType: 'address' },
		],
		outputs: [],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'unpause',
		inputs: [],
		outputs: [],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'withdraw',
		inputs: [
			{
				name: 'key',
				type: 'tuple',
				internalType: 'struct PoolKey',
				components: [
					{
						name: 'currency0',
						type: 'address',
						internalType: 'Currency',
					},
					{
						name: 'currency1',
						type: 'address',
						internalType: 'Currency',
					},
					{ name: 'fee', type: 'uint24', internalType: 'uint24' },
					{
						name: 'tickSpacing',
						type: 'int24',
						internalType: 'int24',
					},
					{
						name: 'hooks',
						type: 'address',
						internalType: 'contract IHooks',
					},
				],
			},
			{ name: 'amount', type: 'int256', internalType: 'int256' },
		],
		outputs: [],
		stateMutability: 'nonpayable',
	},
	{
		type: 'event',
		name: 'Borrow',
		inputs: [
			{
				name: 'user',
				type: 'address',
				indexed: true,
				internalType: 'address',
			},
			{
				name: 'poolId',
				type: 'bytes32',
				indexed: true,
				internalType: 'PoolId',
			},
			{
				name: 'amount',
				type: 'int256',
				indexed: false,
				internalType: 'int256',
			},
		],
		anonymous: false,
	},
	{
		type: 'event',
		name: 'Deposit',
		inputs: [
			{
				name: 'user',
				type: 'address',
				indexed: true,
				internalType: 'address',
			},
			{
				name: 'poolId',
				type: 'bytes32',
				indexed: true,
				internalType: 'PoolId',
			},
			{
				name: 'amount',
				type: 'int256',
				indexed: false,
				internalType: 'int256',
			},
		],
		anonymous: false,
	},
	{
		type: 'event',
		name: 'Liquidation',
		inputs: [
			{
				name: 'liquidator',
				type: 'address',
				indexed: true,
				internalType: 'address',
			},
			{
				name: 'user',
				type: 'address',
				indexed: true,
				internalType: 'address',
			},
			{
				name: 'poolId',
				type: 'bytes32',
				indexed: true,
				internalType: 'PoolId',
			},
			{
				name: 'debtAmount',
				type: 'uint256',
				indexed: false,
				internalType: 'uint256',
			},
			{
				name: 'collateralLiquidated',
				type: 'uint256',
				indexed: false,
				internalType: 'uint256',
			},
		],
		anonymous: false,
	},
	{
		type: 'event',
		name: 'OwnershipTransferred',
		inputs: [
			{
				name: 'user',
				type: 'address',
				indexed: true,
				internalType: 'address',
			},
			{
				name: 'newOwner',
				type: 'address',
				indexed: true,
				internalType: 'address',
			},
		],
		anonymous: false,
	},
	{
		type: 'event',
		name: 'Paused',
		inputs: [
			{
				name: 'owner',
				type: 'address',
				indexed: true,
				internalType: 'address',
			},
		],
		anonymous: false,
	},
	{
		type: 'event',
		name: 'Repay',
		inputs: [
			{
				name: 'user',
				type: 'address',
				indexed: true,
				internalType: 'address',
			},
			{
				name: 'poolId',
				type: 'bytes32',
				indexed: true,
				internalType: 'PoolId',
			},
			{
				name: 'amount',
				type: 'int256',
				indexed: false,
				internalType: 'int256',
			},
		],
		anonymous: false,
	},
	{
		type: 'event',
		name: 'Unpaused',
		inputs: [
			{
				name: 'owner',
				type: 'address',
				indexed: true,
				internalType: 'address',
			},
		],
		anonymous: false,
	},
	{
		type: 'event',
		name: 'Withdraw',
		inputs: [
			{
				name: 'user',
				type: 'address',
				indexed: true,
				internalType: 'address',
			},
			{
				name: 'poolId',
				type: 'bytes32',
				indexed: true,
				internalType: 'PoolId',
			},
			{
				name: 'amount',
				type: 'int256',
				indexed: false,
				internalType: 'int256',
			},
		],
		anonymous: false,
	},
	{ type: 'error', name: 'HookNotImplemented', inputs: [] },
	{ type: 'error', name: 'NotPoolManager', inputs: [] },
	{ type: 'error', name: 'OracleCardinalityCannotBeZero', inputs: [] },
	{
		type: 'error',
		name: 'TargetPredatesOldestObservation',
		inputs: [
			{ name: 'oldestTimestamp', type: 'uint32', internalType: 'uint32' },
			{ name: 'targetTimestamp', type: 'uint32', internalType: 'uint32' },
		],
	},
]

export const MILADY_BANK_ROUTER_ABI = [
	{
		type: 'constructor',
		inputs: [
			{
				name: '_poolManager',
				type: 'address',
				internalType: 'contract IPoolManager',
			},
			{
				name: '_bank',
				type: 'address',
				internalType: 'contract MiladyBank',
			},
		],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'bank',
		inputs: [],
		outputs: [
			{ name: '', type: 'address', internalType: 'contract MiladyBank' },
		],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'borrow',
		inputs: [
			{
				name: 'key',
				type: 'tuple',
				internalType: 'struct PoolKey',
				components: [
					{
						name: 'currency0',
						type: 'address',
						internalType: 'Currency',
					},
					{
						name: 'currency1',
						type: 'address',
						internalType: 'Currency',
					},
					{ name: 'fee', type: 'uint24', internalType: 'uint24' },
					{
						name: 'tickSpacing',
						type: 'int24',
						internalType: 'int24',
					},
					{
						name: 'hooks',
						type: 'address',
						internalType: 'contract IHooks',
					},
				],
			},
			{ name: 'borrowAmount', type: 'int256', internalType: 'int256' },
			{ name: 'minAmountOut', type: 'int256', internalType: 'int256' },
		],
		outputs: [],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'borrowedInWindow',
		inputs: [{ name: '', type: 'address', internalType: 'address' }],
		outputs: [{ name: '', type: 'uint256', internalType: 'uint256' }],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'deposit',
		inputs: [
			{
				name: 'key',
				type: 'tuple',
				internalType: 'struct PoolKey',
				components: [
					{
						name: 'currency0',
						type: 'address',
						internalType: 'Currency',
					},
					{
						name: 'currency1',
						type: 'address',
						internalType: 'Currency',
					},
					{ name: 'fee', type: 'uint24', internalType: 'uint24' },
					{
						name: 'tickSpacing',
						type: 'int24',
						internalType: 'int24',
					},
					{
						name: 'hooks',
						type: 'address',
						internalType: 'contract IHooks',
					},
				],
			},
			{ name: 'depositAmount', type: 'int256', internalType: 'int256' },
		],
		outputs: [],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'depositAndBorrow',
		inputs: [
			{
				name: 'key',
				type: 'tuple',
				internalType: 'struct PoolKey',
				components: [
					{
						name: 'currency0',
						type: 'address',
						internalType: 'Currency',
					},
					{
						name: 'currency1',
						type: 'address',
						internalType: 'Currency',
					},
					{ name: 'fee', type: 'uint24', internalType: 'uint24' },
					{
						name: 'tickSpacing',
						type: 'int24',
						internalType: 'int24',
					},
					{
						name: 'hooks',
						type: 'address',
						internalType: 'contract IHooks',
					},
				],
			},
			{ name: 'depositAmount', type: 'int256', internalType: 'int256' },
			{ name: 'borrowAmount', type: 'int256', internalType: 'int256' },
			{ name: 'minAmountOut', type: 'int256', internalType: 'int256' },
			{ name: 'maxAmountIn', type: 'int256', internalType: 'int256' },
		],
		outputs: [],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'emergencyWithdraw',
		inputs: [
			{
				name: 'key',
				type: 'tuple',
				internalType: 'struct PoolKey',
				components: [
					{
						name: 'currency0',
						type: 'address',
						internalType: 'Currency',
					},
					{
						name: 'currency1',
						type: 'address',
						internalType: 'Currency',
					},
					{ name: 'fee', type: 'uint24', internalType: 'uint24' },
					{
						name: 'tickSpacing',
						type: 'int24',
						internalType: 'int24',
					},
					{
						name: 'hooks',
						type: 'address',
						internalType: 'contract IHooks',
					},
				],
			},
			{ name: 'withdrawAmount', type: 'int256', internalType: 'int256' },
		],
		outputs: [],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'lastBorrowTime',
		inputs: [{ name: '', type: 'address', internalType: 'address' }],
		outputs: [{ name: '', type: 'uint256', internalType: 'uint256' }],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'owner',
		inputs: [],
		outputs: [{ name: '', type: 'address', internalType: 'address' }],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'pause',
		inputs: [],
		outputs: [],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'paused',
		inputs: [],
		outputs: [{ name: '', type: 'bool', internalType: 'bool' }],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'poolManager',
		inputs: [],
		outputs: [
			{
				name: '',
				type: 'address',
				internalType: 'contract IPoolManager',
			},
		],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'repay',
		inputs: [
			{
				name: 'key',
				type: 'tuple',
				internalType: 'struct PoolKey',
				components: [
					{
						name: 'currency0',
						type: 'address',
						internalType: 'Currency',
					},
					{
						name: 'currency1',
						type: 'address',
						internalType: 'Currency',
					},
					{ name: 'fee', type: 'uint24', internalType: 'uint24' },
					{
						name: 'tickSpacing',
						type: 'int24',
						internalType: 'int24',
					},
					{
						name: 'hooks',
						type: 'address',
						internalType: 'contract IHooks',
					},
				],
			},
			{ name: 'repayAmount', type: 'int256', internalType: 'int256' },
			{ name: 'maxAmountIn', type: 'int256', internalType: 'int256' },
		],
		outputs: [],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'repayAndWithdraw',
		inputs: [
			{
				name: 'key',
				type: 'tuple',
				internalType: 'struct PoolKey',
				components: [
					{
						name: 'currency0',
						type: 'address',
						internalType: 'Currency',
					},
					{
						name: 'currency1',
						type: 'address',
						internalType: 'Currency',
					},
					{ name: 'fee', type: 'uint24', internalType: 'uint24' },
					{
						name: 'tickSpacing',
						type: 'int24',
						internalType: 'int24',
					},
					{
						name: 'hooks',
						type: 'address',
						internalType: 'contract IHooks',
					},
				],
			},
			{ name: 'repayAmount', type: 'int256', internalType: 'int256' },
			{ name: 'withdrawAmount', type: 'int256', internalType: 'int256' },
			{ name: 'maxAmountIn', type: 'int256', internalType: 'int256' },
			{ name: 'minAmountOut', type: 'int256', internalType: 'int256' },
		],
		outputs: [],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'transferOwnership',
		inputs: [
			{ name: 'newOwner', type: 'address', internalType: 'address' },
		],
		outputs: [],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'unpause',
		inputs: [],
		outputs: [],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'withdraw',
		inputs: [
			{
				name: 'key',
				type: 'tuple',
				internalType: 'struct PoolKey',
				components: [
					{
						name: 'currency0',
						type: 'address',
						internalType: 'Currency',
					},
					{
						name: 'currency1',
						type: 'address',
						internalType: 'Currency',
					},
					{ name: 'fee', type: 'uint24', internalType: 'uint24' },
					{
						name: 'tickSpacing',
						type: 'int24',
						internalType: 'int24',
					},
					{
						name: 'hooks',
						type: 'address',
						internalType: 'contract IHooks',
					},
				],
			},
			{ name: 'withdrawAmount', type: 'int256', internalType: 'int256' },
		],
		outputs: [],
		stateMutability: 'nonpayable',
	},
	{
		type: 'event',
		name: 'Borrowed',
		inputs: [
			{
				name: 'user',
				type: 'address',
				indexed: true,
				internalType: 'address',
			},
			{
				name: 'token',
				type: 'address',
				indexed: false,
				internalType: 'address',
			},
			{
				name: 'amount',
				type: 'int256',
				indexed: false,
				internalType: 'int256',
			},
			{
				name: 'amountOut',
				type: 'int256',
				indexed: false,
				internalType: 'int256',
			},
		],
		anonymous: false,
	},
	{
		type: 'event',
		name: 'Deposited',
		inputs: [
			{
				name: 'user',
				type: 'address',
				indexed: true,
				internalType: 'address',
			},
			{
				name: 'token',
				type: 'address',
				indexed: false,
				internalType: 'address',
			},
			{
				name: 'amount',
				type: 'int256',
				indexed: false,
				internalType: 'int256',
			},
		],
		anonymous: false,
	},
	{
		type: 'event',
		name: 'OwnershipTransferred',
		inputs: [
			{
				name: 'user',
				type: 'address',
				indexed: true,
				internalType: 'address',
			},
			{
				name: 'newOwner',
				type: 'address',
				indexed: true,
				internalType: 'address',
			},
		],
		anonymous: false,
	},
	{
		type: 'event',
		name: 'Paused',
		inputs: [
			{
				name: 'owner',
				type: 'address',
				indexed: true,
				internalType: 'address',
			},
		],
		anonymous: false,
	},
	{
		type: 'event',
		name: 'Repaid',
		inputs: [
			{
				name: 'user',
				type: 'address',
				indexed: true,
				internalType: 'address',
			},
			{
				name: 'token',
				type: 'address',
				indexed: false,
				internalType: 'address',
			},
			{
				name: 'amount',
				type: 'int256',
				indexed: false,
				internalType: 'int256',
			},
			{
				name: 'amountIn',
				type: 'int256',
				indexed: false,
				internalType: 'int256',
			},
		],
		anonymous: false,
	},
	{
		type: 'event',
		name: 'Unpaused',
		inputs: [
			{
				name: 'owner',
				type: 'address',
				indexed: true,
				internalType: 'address',
			},
		],
		anonymous: false,
	},
	{
		type: 'event',
		name: 'Withdrawn',
		inputs: [
			{
				name: 'user',
				type: 'address',
				indexed: true,
				internalType: 'address',
			},
			{
				name: 'token',
				type: 'address',
				indexed: false,
				internalType: 'address',
			},
			{
				name: 'amount',
				type: 'int256',
				indexed: false,
				internalType: 'int256',
			},
		],
		anonymous: false,
	},
]
