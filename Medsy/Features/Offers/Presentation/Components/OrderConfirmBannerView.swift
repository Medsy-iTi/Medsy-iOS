//  OrderConfirmBannerView.swift
//  Medsy
//
//  Created by Antoneos Philip on 22/07/2026.

import SwiftUI

struct OrderConfirmBannerView: View {
    @Environment(LanguageManager.self) private var languageManager

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: "clock")
                .font(.system(size: 22, weight: .regular))
                .foregroundStyle(AppColor.green)

            Text("orderConfirm.noticeText".localized)
                .font(AppColor.sans(12))
                .foregroundStyle(AppColor.textSec)
                .multilineTextAlignment(.trailing)
                .lineSpacing(3)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .environment(\.layoutDirection, languageManager.isRTL ? .rightToLeft : .leftToRight)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColor.green.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppColor.green.opacity(0.4), lineWidth: 1)
                )
        )
    }
}
