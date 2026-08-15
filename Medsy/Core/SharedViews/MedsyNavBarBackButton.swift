//
//  MedsyNavBarBackButton.swift
//  Medsy
//
//  Created by Ehab Salah on 23/07/2026.
//

import SwiftUI

struct MedsyNavBarBackButton: View {
    @Environment(LanguageManager.self) private var languageManager
    let action: () -> Void
    var isEnabled = true

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 3)
                    .overlay(
                        Circle()
                            .stroke(Color.gray.opacity(0.12), lineWidth: 1)
                    )

                Image(systemName: languageManager.isRTL ? "chevron.right" : "chevron.left")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(AppColor.green)
            }
            .frame(width: 40, height: 40)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.45)
        .accessibilityLabel("accessibility.back".localized)
    }
}
