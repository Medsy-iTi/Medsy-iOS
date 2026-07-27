//
//  PharmacyEmptyStateView.swift
//  Medsy
//
//  Created by Shahudaa on 26/07/2026.
//



import SwiftUI

struct PharmacyEmptyStateView: View {
    let lottieName: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: PharmacySpacing.md) {
            Spacer()

            PharmacyLottieView(name: lottieName)
                .frame(width: 200, height: 200)

            Text(title)
                .font(PharmacyColor.sans(18, .bold))
                .foregroundStyle(PharmacyColor.textPrimary)

            Text(message)
                .font(PharmacyColor.sans(14))
                .foregroundStyle(PharmacyColor.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, PharmacySpacing.xl)

			Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

extension PharmacyEmptyStateView {

    static var noCompletedOrders: PharmacyEmptyStateView {
        PharmacyEmptyStateView(
            lottieName: "no_data_found",
            title: "orders_empty_none_title".localized,
            message: "orders_empty_none_message".localized
        )
    }


    static var noSearchResults: PharmacyEmptyStateView {
        PharmacyEmptyStateView(
            lottieName: "no_data_found",
            title: "orders_empty_filtered_title".localized,
            message: "orders_empty_filtered_message".localized
        )
    }
}

#Preview {
    PharmacyEmptyStateView.noCompletedOrders
        .background(PharmacyColor.bg)
}
