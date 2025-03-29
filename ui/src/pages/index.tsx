import Head from 'next/head'
import Link from 'next/link'
import styles from '@/styles/Home.module.css'

export default function Home() {
	return (
		<>
			<Head>
				<title>MiladyBank</title>
				<meta
					name='description'
					content='Next generation DeFi lending'
				/>
			</Head>
			<div className={styles.page}>
				<main className={styles.main}>
					<h1 className={styles.title}>Bank Protocol</h1>
					<p className={styles.description}>
						A borrowing and lending protocol powered by Uniswap V4
					</p>

					<div className={styles.ctas}>
						<Link href='/dashboard' className={styles.primary}>
							Launch App
						</Link>
						<Link href='/markets' className={styles.secondary}>
							View Markets
						</Link>
					</div>
				</main>
			</div>
		</>
	)
}
