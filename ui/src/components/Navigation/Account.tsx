import { useAccount, useDisconnect, useEnsAvatar, useEnsName } from 'wagmi'
import styles from './Account.module.css'

export function Account() {
	const { address } = useAccount()
	const { disconnect } = useDisconnect()
	const { data: ensName } = useEnsName({ address })
	const { data: ensAvatar } = useEnsAvatar({ name: ensName! })

	function shortenAddress(address: string): string {
		if (!address) return ''
		return `${address.slice(0, 6)}...${address.slice(-4)}`
	}

	return (
		<div className={styles.accountContainer}>
			{ensAvatar && (
				<img
					className={styles.avatar}
					alt='ENS Avatar'
					src={ensAvatar}
				/>
			)}
			{address && (
				<div className={styles.addressInfo}>
					{ensName
						? `${ensName} (${shortenAddress(address)})`
						: shortenAddress(address)}
				</div>
			)}
			<button
				className={styles.disconnectButton}
				onClick={() => disconnect()}
			>
				Disconnect
			</button>
		</div>
	)
}
