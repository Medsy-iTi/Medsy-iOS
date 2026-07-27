//  HomeHeaderView.swift
//  Medsy
//
//  Created by Antoneos Philip on 14/07/2026.
//

import SwiftUI

struct HomeHeaderView: View {
    @Environment(LanguageManager.self) private var languageManager
    let homeAddress: String
    let onAddressTap: () -> Void

    var body: some View {
        HStack(spacing: MedsySpacing.sm) {
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    languageManager.toggle()
                }
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "globe")
                    Text(languageManager.currentLanguage.toggled.displayName)
                        .font(AppColor.sans(13, .bold))
                }
                .foregroundStyle(AppColor.textPrim)
                .padding(.horizontal, 10)
                .frame(minHeight: 44)
                .background(AppColor.card, in: Capsule())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("common.language".localized)
            
            Spacer()
            
            Button(action: onAddressTap) {
                HStack(spacing: 7) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.subheadline)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("home.deliveryTo".localized)
                            .font(AppColor.sans(11, .regular))
                            .foregroundStyle(AppColor.textSec)

                        Text(homeAddress)
                            .font(AppColor.sans(14, .bold))
                            .foregroundStyle(AppColor.textPrim)
                            .lineLimit(1)
                    }

                    Image(systemName: "chevron.forward")
                        .font(.caption.weight(.semibold))
                }
                .foregroundStyle(AppColor.textPrim)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(
                "\("home.deliveryTo".localized), \(homeAddress)"
            )
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}
