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
    @ObservedObject private var appSettings = AppSettings.shared

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
        HStack {
            Button {
                onBack?()
            } label: {
                Image(systemName: languageManager.isRTL ? "arrow.right" : "arrow.left")
                    .foregroundStyle(AppColor.textPrim)
                    .imageScale(.large)
            }
            .frame(width: 44, height: 44)
            .opacity(onBack == nil ? 0 : 1)
            .disabled(onBack == nil)

            Spacer()

            if let title {
                Text(title)
                    .font(MedsyFont.title())
                    .foregroundStyle(AppColor.textPrim)
            }

            Spacer()

            trailing()
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, MedsySpacing.md)
        .frame(height: 56)
        .background(AppColor.bg)
    }
}

