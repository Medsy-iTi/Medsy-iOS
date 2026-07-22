//  OfferDetailsHeaderView.swift
//  Medsy
//
//  Created by Antoneos Philip on 22/07/2026.

import SwiftUI

struct OfferDetailsHeaderView: View {
    @Environment(LanguageManager.self) private var languageManager
    let pharmacyName: String
    let managerName: String
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

            VStack(alignment: .leading, spacing: 4) {
                Text(pharmacyName)
                    .font(AppColor.sans(20, .bold))
                    .foregroundStyle(AppColor.textPrim)

                Text(managerName)
                    .font(AppColor.sans(13))
                    .foregroundStyle(AppColor.textSec)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}
