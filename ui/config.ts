import { http, createConfig } from 'wagmi'
import { base, mainnet, unichain } from 'wagmi/chains'

export const config = createConfig({
	chains: [base, mainnet, unichain],
	transports: {
		[base.id]: http(),
		[mainnet.id]: http(),
		[unichain.id]: http(),
	},
})
