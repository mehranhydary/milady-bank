import Image from 'next/image'
import styles from '@/styles/Markets.module.css'
import { useState } from 'react'

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
		symbol: 'ETH',
		name: 'Ethereum',
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

const MarketRow = ({ asset }: { asset: Asset }) => {
	const [dropdownOpen, setDropdownOpen] = useState(false)
	return (
		<tr key={asset.symbol}>
			<td>
				<div className={styles.assetInfo}>
					<Image
						src={asset.icon}
						alt={asset.symbol}
						width={24}
						height={24}
						className={styles.assetIcon}
					/>
					<span>{asset.symbol}</span>
				</div>
			</td>
			<td>{asset.totalSupply}</td>
			<td className={styles.apy}>{asset.supplyAPY}</td>
			<td>{asset.totalBorrow}</td>
			<td className={styles.apy}>{asset.borrowAPY}</td>
			<td>
				<div className={styles.actions}>
					<div className={styles.actionContainer}>
						<div
							className={styles.actionButton}
							// onClick={() => setDropdownOpen(!dropdownOpen)}
						>
							⋯
						</div>
						{dropdownOpen && (
							<div className={styles.dropdown}>
								<div className={styles.dropdownItem}>
									Supply
								</div>
								<div className={styles.dropdownItem}>
									Borrow
								</div>
							</div>
						)}
					</div>
				</div>
			</td>
		</tr>
	)
}

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
						<MarketRow key={asset.symbol} asset={asset} />
					))}
				</tbody>
			</table>
		</div>
	)
}
