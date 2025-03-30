import styles from '@/styles/Navigation.module.css'

import Link from 'next/link'
import { useRouter } from 'next/router'

import { Account } from './Account'
import { WalletOptions } from './WalletOptions'
import { useAccount } from 'wagmi'
import { useEffect } from 'react'

function ConnectWallet() {
	const { isConnected } = useAccount()
	return isConnected ? <Account /> : <WalletOptions />
}

export default function Navigation() {
	const { isConnected } = useAccount()
	const router = useRouter()

	useEffect(() => {
		if (!isConnected) {
			router.push('/')
		}
	}, [isConnected, router])

	return (
		<nav className={styles.nav}>
			{isConnected ? (
				<div>
					<Link
						href='/'
						className={router.pathname === '/' ? styles.active : ''}
					>
						Home
					</Link>
					<Link
						href='/dashboard'
						className={
							router.pathname === '/dashboard'
								? styles.active
								: ''
						}
					>
						Dashboard
					</Link>
					<Link
						href='/markets'
						className={
							router.pathname === '/markets' ? styles.active : ''
						}
					>
						Markets
					</Link>
				</div>
			) : (
				<div></div>
			)}

			<ConnectWallet />
		</nav>
	)
}
