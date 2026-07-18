//
//  PharmacyHomeView.swift
//  Medsy-Pharmacy
//
//  Created by Ehab Salah on 18/07/2026.
//

import SwiftUI

struct PharmacyHomeView: View {
    private let metrics = [
        PharmacyHomeMetric(titleKey: "pharmacy.home.new_orders", value: "23", icon: "bag.fill", tint: PharmacyColor.primary),
        PharmacyHomeMetric(titleKey: "pharmacy.home.preparing", value: "18", icon: "shippingbox.fill", tint: PharmacyColor.secondary),
        PharmacyHomeMetric(titleKey: "pharmacy.home.delivered_today", value: "45", icon: "cross.case.fill", tint: PharmacyColor.success),
        PharmacyHomeMetric(titleKey: "pharmacy.home.sales", value: "3,240", icon: "chart.pie.fill", tint: PharmacyColor.warning)
    ]

    private let orders = [
        PharmacyHomeOrder(id: "1258", customerNameKey: "pharmacy.home.customer.ahmed", addressKey: "pharmacy.home.address.maadi", minutesAgo: 5, status: .new),
        PharmacyHomeOrder(id: "1257", customerNameKey: "pharmacy.home.customer.mona", addressKey: "pharmacy.home.address.nozha", minutesAgo: 15, status: .preparing),
        PharmacyHomeOrder(id: "1256", customerNameKey: "pharmacy.home.customer.youssef", addressKey: "pharmacy.home.address.dar_elsalam", minutesAgo: 35, status: .delivered)
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: PharmacySpacing.lg) {
                PharmacyHomeHeaderView()
                PharmacyHeroCard()
                PharmacyMetricsGrid(metrics: metrics)
                PharmacyRecentOrdersView(orders: orders)
                PharmacyPrimaryButton(title: "pharmacy.home.view_all_orders".localized, action: {})
            }
            .padding(.horizontal, PharmacySpacing.md)
            .padding(.top, PharmacySpacing.sm)
            .padding(.bottom, PharmacySpacing.md)
        }
        .background(PharmacyColor.bg)
    }
}

#Preview("Arabic") {
    PharmacyHomeView()
        .environment(LanguageManager.shared)
        .pharmacyLocalizedEnvironment()
}
