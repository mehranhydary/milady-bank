import React from 'react'
import styles from '@/styles/Dashboard.module.css'

export const EmptyState = ({ message }: { message: string }) => (
	<div className={styles.emptyState}>{message}</div>
)
