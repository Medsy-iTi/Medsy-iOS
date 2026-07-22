//  OrderReviewHeaderView.swift
//  Medsy
//
//  Created by Antoneos Philip on 22/07/2026.

import SwiftUI

struct OrderReviewHeaderView: View {
    @Environment(LanguageManager.self) private var languageManager
    let onBack: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                ZStack {
                    Circle()
                        .fill(AppColor.card)
                        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 2)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(AppColor.textPrim)
                        .flipsForRightToLeftLayoutDirection(false)
                }
                .frame(width: 44, height: 44)
            }

            Spacer()

            Text("orderReview.title".localized)
                .font(AppColor.sans(20, .bold))
                .foregroundStyle(AppColor.textPrim)
                .multilineTextAlignment(.center)

            Spacer()

            Color.clear
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}
