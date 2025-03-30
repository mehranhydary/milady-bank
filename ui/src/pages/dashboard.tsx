import Head from 'next/head'
import styles from '@/styles/Dashboard.module.css'
import Image from 'next/image'
import { Card } from '@/components/PageComponents/Dashboard/Card'
import { EmptyState } from '@/components/PageComponents/Dashboard/EmptyState'
import { InfoAlert } from '@/components/PageComponents/Dashboard/InfoAlert'

// Asset row component
interface AssetRowProps {
	symbol: string
	logoSrc: string
	available?: string
	apy: string
	isGho?: boolean
	leverage?: string
	walletBalance?: string
	canBeCollateral?: boolean
}

const AssetRow = ({
	symbol,
	logoSrc,
	available,
	apy,
	isGho = false,
	leverage,
	walletBalance,
	canBeCollateral,
}: AssetRowProps) => (
	<div className={styles.assetRow}>
		<div className={styles.assetInfo}>
			<Image
				src={logoSrc}
				alt={symbol}
				width={24}
				height={24}
				className={styles.assetIcon}
			/>
			<span>{symbol}</span>
		</div>

		{walletBalance ? (
			<>
				<div>{walletBalance}</div>
				<div>{apy}</div>
				<div>{canBeCollateral ? '✓' : ''}</div>
				<button className={styles.actionButton}>Supply</button>
				<span>⋯</span>
			</>
		) : (
			<>
				<div>
					<div>
						Available <span className={styles.infoIcon}>ⓘ</span>
					</div>
					<div>{available}</div>
				</div>
				<div>
					<div>
						{isGho ? 'APY, borrow rate' : 'APY, variable'}{' '}
						<span className={styles.infoIcon}>ⓘ</span>
					</div>
					<div>{apy}</div>
					{leverage && (
						<div>
							{leverage}{' '}
							<span className={styles.infoIcon}>ⓘ</span>
						</div>
					)}
				</div>
				<div>
					<button className={styles.actionButton}>Borrow</button>
					<button className={styles.detailsButton}>Details</button>
				</div>
			</>
		)}
	</div>
)

// Your Supplies component
const YourSupplies = () => (
	<Card title='Your supplies'>
		<EmptyState message='Nothing supplied yet' />
	</Card>
)

// Your Borrows component
const YourBorrows = () => (
	<Card title={<>Your borrows</>}>
		<EmptyState message='Nothing borrowed yet' />
	</Card>
)

// Assets to Supply component
const AssetsToSupply = () => (
	<Card title='Assets to supply' hideButton>
		<div>
			<label>
				<input type='checkbox' /> Show assets with 0 balance
			</label>
		</div>

		<AssetRow
			symbol='ETH'
			logoSrc='https://app.aave.com/icons/tokens/eth.svg'
			walletBalance='0.0584277'
			apy='1.98 %'
			canBeCollateral={true}
		/>
	</Card>
)

// Assets to Borrow component
const AssetsToBorrow = () => (
	<Card title='Assets to borrow' hideButton>
		<InfoAlert message='To borrow you need to supply any asset to be used as collateral.' />

		<AssetRow
			symbol='ETH'
			logoSrc='https://app.aave.com/icons/tokens/eth.svg'
			available='0'
			apy='2.66 %'
		/>

		<AssetRow
			symbol='USDC'
			logoSrc='https://app.aave.com/icons/tokens/usdc.svg'
			available='0'
			apy='0.48 %'
		/>
	</Card>
)

export default function Dashboard() {
	return (
		<>
			<Head>
				<title>Dashboard | MiladyBank</title>
				<meta name='description' content='MiladyBank Dashboard' />
			</Head>
			<div className={styles.page}>
				<main className={styles.main}>
					<h1>Core Instance</h1>
					<p>
						Main Ethereum market with the largest selection of
						assets and yield options
					</p>

					<div className={styles.infoRow}>
						<div>
							<div>Net worth</div>
							<div>$0</div>
						</div>
						<div>
							<div>
								Net APY{' '}
								<span className={styles.infoIcon}>ⓘ</span>
							</div>
							<div>—</div>
						</div>
						<button className={styles.actionButton}>
							VIEW TRANSACTIONS
						</button>
					</div>

					<div className={styles.grid}>
						<YourSupplies />
						<YourBorrows />
						<AssetsToSupply />
						<AssetsToBorrow />
					</div>
				</main>
			</div>
		</>
	)
}
