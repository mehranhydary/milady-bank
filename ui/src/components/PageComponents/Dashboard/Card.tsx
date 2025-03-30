import React, { ReactNode } from 'react'
import styles from '@/styles/Dashboard.module.css'

// Card component for each section
interface CardProps {
	title: ReactNode
	children: ReactNode
	hideButton?: boolean
}

export const Card = ({ title, children, hideButton = false }: CardProps) => (
	<div className={styles.card}>
		<div className={styles.sectionHeader}>
			<h2>{title}</h2>
			{hideButton && (
				<button className={styles.hideButton}>Hide —</button>
			)}
		</div>
		{children}
	</div>
)
