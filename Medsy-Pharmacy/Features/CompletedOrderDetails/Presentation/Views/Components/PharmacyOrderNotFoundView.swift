//
//  PharmacyOrderNotFoundView.swift
//  Medsy
//
//  Created by Shahudaa on 26/07/2026.
//



import SwiftUI

struct PharmacyOrderNotFoundView: View {
    let onBack: (() -> Void)?

    var body: some View {
        VStack(spacing: PharmacySpacing.lg) {
            Image(systemName: "doc.questionmark")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(PharmacyColor.textSecondary.opacity(0.5))
            Text("completed_order.not_found".localized)
                .font(PharmacyColor.sans(17, .semibold))
                .foregroundStyle(PharmacyColor.textPrimary)
            if let onBack = onBack {
                Button("common.back".localized, action: onBack)
                    .font(PharmacyColor.sans(15, .semibold))
                    .foregroundStyle(PharmacyColor.primary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(PharmacyColor.bg)
    }
}

#Preview {
    PharmacyOrderNotFoundView(onBack: {})
}
