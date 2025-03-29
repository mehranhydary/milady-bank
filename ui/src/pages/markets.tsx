import Head from 'next/head'
import styles from '@/styles/Markets.module.css'
import MarketsTable from '@/components/PageComponents/Markets/MarketsTable'

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
					<p className={styles.description}>
						Supply assets to earn interest or borrow against your
						collateral.
					</p>
					<MarketsTable />
				</main>
			</div>
		</>
	)
}
