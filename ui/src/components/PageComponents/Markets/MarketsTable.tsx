import Image from 'next/image'
import styles from '@/styles/Markets.module.css'

type Asset = {
	symbol: string
	name: string
	icon: string
	totalSupply: string
	supplyAPY: string
	totalBorrow: string
	borrowAPY: string
}

const assets: Asset[] = [
	{
		symbol: 'WETH',
		name: 'Wrapped ETH',
		icon: 'https://app.aave.com/icons/tokens/eth.svg',
		totalSupply: '1,234.56 ETH',
		supplyAPY: '2.5%',
		totalBorrow: '987.65 ETH',
		borrowAPY: '3.2%',
	},
	{
		symbol: 'USDC',
		name: 'USD Coin',
		icon: 'https://app.aave.com/icons/tokens/usdc.svg',
		totalSupply: '5,678,901 USDC',
		supplyAPY: '4.1%',
		totalBorrow: '3,456,789 USDC',
		borrowAPY: '5.3%',
	},
]

export default function MarketsTable() {
	return (
		<div className={styles.table}>
			<table>
				<thead>
					<tr>
						<th>Asset</th>
						<th>Total Supply</th>
						<th>Supply APY</th>
						<th>Total Borrow</th>
						<th>Borrow APY</th>
						<th>Actions</th>
					</tr>
				</thead>
				<tbody>
					{assets.map((asset) => (
						<tr key={asset.symbol}>
							<td className={styles.assetCell}>
								<div className={styles.asset}>
									<div className={styles.assetIcon}>
										<Image
											src={asset.icon}
											alt={asset.symbol}
											width={24}
											height={24}
										/>
									</div>
									<div className={styles.assetInfo}>
										<div className={styles.assetSymbol}>
											{asset.symbol}
										</div>
										<div className={styles.assetName}>
											{asset.name}
										</div>
									</div>
								</div>
							</td>
							<td>{asset.totalSupply}</td>
							<td className={styles.apy}>{asset.supplyAPY}</td>
							<td>{asset.totalBorrow}</td>
							<td className={styles.apy}>{asset.borrowAPY}</td>
							<td>
								<div className={styles.actions}>
									<button className={styles.actionButton}>
										Supply
									</button>
									<button className={styles.actionButton}>
										Borrow
									</button>
								</div>
							</td>
						</tr>
					))}
				</tbody>
			</table>
		</div>
	)
}
