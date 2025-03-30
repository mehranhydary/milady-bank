import React from 'react'
import styles from '@/styles/Dashboard.module.css'
import Image from 'next/image'
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

export const AssetRow = ({
	symbol,
	logoSrc,
	available,
	apy,
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
