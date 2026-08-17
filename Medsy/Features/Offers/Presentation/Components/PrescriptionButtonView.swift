//
//  PrescriptionButtonView.swift
//  Medsy
//
//  Created by Antoneos Philip on 25/07/2026.
//

import SwiftUI

struct PrescriptionButtonView: View {
    @Environment(LanguageManager.self) private var languageManager
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Spacer()

                Text("offers.details.viewPrescription".localized)
                    .font(AppColor.sans(15, .bold))
                    .foregroundStyle(AppColor.textPrim)

                Image(systemName: "doc.text.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(AppColor.textSec)

                Spacer()
            }
            .environment(\.layoutDirection, languageManager.isRTL ? .rightToLeft : .leftToRight)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColor.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppColor.border, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
