import '@/styles/globals.css'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import type { AppProps } from 'next/app'
import { WagmiProvider } from 'wagmi'
import { config } from '../../config'
import Navigation from '@/components/Navigation'

const queryClient = new QueryClient()

export default function App({ Component, pageProps }: AppProps) {
	return (
		<>
			<WagmiProvider config={config}>
				<QueryClientProvider client={queryClient}>
					<Navigation />
					<Component {...pageProps} />
				</QueryClientProvider>
			</WagmiProvider>
		</>
	)
}
