import Head from 'next/head'
import styles from '@/styles/Dashboard.module.css'

export default function Dashboard() {
	return (
		<>
			<Head>
				<title>Dashboard | MiladyBank</title>
				<meta name='description' content='MiladyBank Dashboard' />
			</Head>
			<div className={styles.page}>
				<main className={styles.main}>
					<h1>Dashboard</h1>
					<div className={styles.grid}>
						<div className={styles.card}>
							<h2>Your Deposits</h2>
							{/* Add deposit content */}
						</div>
						<div className={styles.card}>
							<h2>Your Borrows</h2>
							{/* Add borrow content */}
						</div>
						<div className={styles.card}>
							<h2>Health Factor</h2>
							{/* Add health factor content */}
						</div>
					</div>
				</main>
			</div>
		</>
	)
}
