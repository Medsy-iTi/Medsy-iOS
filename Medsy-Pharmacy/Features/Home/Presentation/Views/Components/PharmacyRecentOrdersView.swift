//  PharmacyRecentOrdersView.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 19/07/2026.
//

import SwiftUI

struct PharmacyRecentOrdersView: View {
    let state: PharmacyHomeViewModel.OrdersState
    let orders: [PharmacyHomeOrder]
    var onSelectOrder: ((PharmacyHomeOrder) -> Void)? = nil
    let onRetry: () -> Void
    let onViewAllOrders: () -> Void

    
    var body: some View {
        VStack(alignment: .leading, spacing: PharmacySpacing.sm) {
            HStack {
                Text("pharmacy.home.recent_orders".localized)
                    .font(PharmacyColor.sans(16, .bold))
                    .foregroundStyle(PharmacyColor.textPrimary)
                Spacer()
                Button("pharmacy.home.view_all".localized, action: onViewAllOrders)
                    .font(PharmacyColor.sans(13, .semibold))
                    .foregroundStyle(PharmacyColor.primary)
            }

            Group {
                switch state {
                case .idle, .loading:
                    VStack(spacing: PharmacySpacing.sm) {
                        ProgressView()
                        Text("pharmacy.home.orders_loading".localized)
                            .font(PharmacyColor.sans(12))
                            .foregroundStyle(PharmacyColor.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, PharmacySpacing.xl)

                case .empty:
                    homeOrderMessage(
                        icon: "tray",
                        title: "pharmacy.home.orders_empty_title".localized,
                        message: "pharmacy.home.orders_empty_message".localized
                    )

                case .failed(let message):
                    ErrorStateView(
                        icon: "exclamationmark.triangle",
                        message: message,
                        retryTitle: "common.retry".localized,
                        onRetry: onRetry
                    )

                case .loaded:
                    VStack(spacing: 0) {
                        ForEach(Array(orders.enumerated()), id: \.element.id) { index, order in
                            Button {
                                onSelectOrder?(order)
                            } label: {
                                PharmacyRecentOrderItem(order: order)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)

                            if index < orders.count - 1 {
                                Divider()
                                    .overlay(PharmacyColor.border)
                                    .padding(.leading, PharmacySpacing.md)
                            }
                        }
                    }
                }
            }
            .background(PharmacyColor.card, in: RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous).stroke(PharmacyColor.border, lineWidth: 1))
        }
    }

    private func homeOrderMessage(icon: String, title: String, message: String) -> some View {
        VStack(spacing: PharmacySpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 30, weight: .medium))
                .foregroundStyle(PharmacyColor.textSecondary)
            Text(title)
                .font(PharmacyColor.sans(14, .bold))
                .foregroundStyle(PharmacyColor.textPrimary)
            Text(message)
                .font(PharmacyColor.sans(12))
                .foregroundStyle(PharmacyColor.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(PharmacySpacing.lg)
    }
}
