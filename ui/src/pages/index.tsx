import Head from 'next/head'
import Link from 'next/link'
import styles from '@/styles/Home.module.css'
import { useAccount } from 'wagmi'

export default function Home() {
	const { isConnected } = useAccount()
	return (
		<>
			<Head>
				<title>MiladyBank</title>
				<meta
					name='description'
					content='Next generation DeFi lending'
				/>
			</Head>
			<div className={styles.container}>
				<div className={styles.grid}></div>
				<main className={styles.main}>
					<div className={styles.logo}>
						<span className={styles.logoText}>Milady Bank</span>
					</div>

					<div className={styles.heroContent}>
						<h1 className={styles.title}>
							Designed for DeFi.
							<br />
							Powered by Uniswap.
						</h1>
						{isConnected && (
							<div className={styles.ctas}>
								<>
									<Link
										href='/dashboard'
										className={styles.primary}
									>
										Launch App
									</Link>
									<Link
										href='/markets'
										className={styles.secondary}
									>
										View Markets
									</Link>
								</>
							</div>
						)}

						<div className={styles.subtitle}>Built on Unichain</div>
					</div>
				</main>
			</div>
		</>
	)
}
