//
//  PharmacyOrderCard.swift
//  Medsy-Pharmacy
//
//  Created by Ehab Salah on 20/07/2026.
//

import SwiftUI

struct PharmacyOrderCard: View {
	let order: PharmacyOrderListItem
	let onAction: () -> Void

	var body: some View {
		PharmacyOrderSummaryCardView(
			orderIdString: String(order.id),
			createdAtRelativeString: order.createdAt.relativeTimeString,
			statusPillText: order.status.titleKey.localized,
			statusPillColor: order.status.tint,
			statusPillBgColor: order.status.tint.opacity(0.12),
			customerName: order.customerName,
			customerPhone: order.phoneNumber,
			deliveryAddress: order.address,
			paymentMethodString: order.paymentMethod.localizedTitle,
			totalAmountString: String(order.amount)
		) {
			PharmacyPrimaryButton(
				title: order.status.actionTitleKey.localized,
				style: order.status.buttonStyle,
				height: 44,
				action: onAction
			)
		}
	}
}
