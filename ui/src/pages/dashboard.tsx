import Head from 'next/head'
import styles from '@/styles/Dashboard.module.css'
import { AssetRow } from '@/components/PageComponents/Dashboard/AssetRow'
import { Card } from '@/components/PageComponents/Dashboard/Card'
import { EmptyState } from '@/components/PageComponents/Dashboard/EmptyState'
import { InfoAlert } from '@/components/PageComponents/Dashboard/InfoAlert'

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
					<h1>Core</h1>
					<p>
						Unichain market with the largest selection of assets and
						yield options
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
