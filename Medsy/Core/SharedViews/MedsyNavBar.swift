//
//  MedsyNavBar.swift
//  Medsy
//
//  Created by Shahudaa on 15/07/2026.
//

import SwiftUI

struct MedsyNavBar<Trailing: View>: View {
    let title: String?
    let onBack: (() -> Void)?
    @ViewBuilder var trailing: () -> Trailing

    @Environment(LanguageManager.self) private var languageManager

    init(
        title: String? = nil,
        onBack: (() -> Void)? = nil,
        @ViewBuilder trailing: @escaping () -> Trailing = { EmptyView() }
    ) {
        self.title = title
        self.onBack = onBack
        self.trailing = trailing
    }

    var body: some View {
        ZStack {
            if let title {
                Text(title)
                    .font(MedsyFont.title())
                    .foregroundStyle(AppColor.textPrim)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity)
            }

            HStack {
                if let onBack {
                    MedsyNavBarBackButton(
                        isRTL: languageManager.isRTL,
                        action: onBack
                    )
                } else {
                    Color.clear
                        .frame(width: 44, height: 44)
                }

                Spacer()

                trailing()
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, MedsySpacing.md)
        .frame(height: 56)
        .background(AppColor.bg)
    }
}
