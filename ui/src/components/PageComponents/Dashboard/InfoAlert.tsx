import React from 'react'
import styles from '@/styles/Dashboard.module.css'

// Info Alert component
export const InfoAlert = ({ message }: { message: string }) => (
	<div className={styles.infoAlert}>
		<span>ⓘ</span>
		<span>{message}</span>
	</div>
)
