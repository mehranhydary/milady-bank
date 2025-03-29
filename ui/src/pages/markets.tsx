import Head from 'next/head'
import styles from '@/styles/Markets.module.css'

export default function Markets() {
	return (
		<>
			<Head>
				<title>Markets | MiladyBank</title>
				<meta name='description' content='MiladyBank Markets' />
			</Head>
			<div className={styles.page}>
				<main className={styles.main}>
					<h1>Markets</h1>
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
							<tbody>{/* Add market rows */}</tbody>
						</table>
					</div>
				</main>
			</div>
		</>
	)
}
