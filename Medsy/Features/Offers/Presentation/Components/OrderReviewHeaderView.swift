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
            Text("orderReview.title".localized)
                .font(AppColor.sans(20, .bold))
                .foregroundStyle(AppColor.textPrim)
                .frame(maxWidth: .infinity, alignment: .trailing)

            Button(action: onBack) {
                Image(systemName: languageManager.isRTL ? "arrow.right" : "arrow.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppColor.textPrim)
                    .frame(width: 36, height: 36)
            }
        }
        .environment(\.layoutDirection, languageManager.isRTL ? .rightToLeft : .leftToRight)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}
