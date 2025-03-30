import * as React from 'react'
import { useConnect } from 'wagmi'
import styles from './WalletOptions.module.css'

export function WalletOptions() {
	const { connect, connectors } = useConnect()
	const [ready, setReady] = React.useState(false)

	const metamaskConnector = connectors.find((c) => c.name === 'MetaMask')

	React.useEffect(() => {
		if (!metamaskConnector) return
		;(async () => {
			const provider = await metamaskConnector.getProvider()
			setReady(!!provider)
		})()
	}, [metamaskConnector])

	if (!metamaskConnector) {
		return null
	}

	return (
		<div
			className={styles.buttonContainer}
			onClick={() => connect({ connector: metamaskConnector })}
			data-disabled={!ready}
		>
			Connect
		</div>
	)
}
