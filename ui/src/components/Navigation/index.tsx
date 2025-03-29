import Link from 'next/link'
import { useRouter } from 'next/router'
import styles from '@/styles/Navigation.module.css'

export default function Navigation() {
	const router = useRouter()

	return (
		<nav className={styles.nav}>
			<Link
				href='/'
				className={router.pathname === '/' ? styles.active : ''}
			>
				Home
			</Link>
			<Link
				href='/dashboard'
				className={
					router.pathname === '/dashboard' ? styles.active : ''
				}
			>
				Dashboard
			</Link>
			<Link
				href='/markets'
				className={router.pathname === '/markets' ? styles.active : ''}
			>
				Markets
			</Link>
		</nav>
	)
}
