//
//  MedsyFilterChip.swift
//  Medsy
//
//  Created by Shahudaa on 15/07/2026.
//

import SwiftUI

struct MedsyFilterChip: View {
    let title: String
    var systemIcon: String? = nil
    var isSelected: Bool = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: MedsySpacing.xxs) {
                if let systemIcon {
                    Image(systemName: systemIcon)
                        .font(.system(size: 12, weight: .semibold))
                }
                Text(title)
                    .font(MedsyFont.bodyMedium(14))
            }
            .padding(.horizontal, MedsySpacing.md)
            .padding(.vertical, MedsySpacing.xs)
            .foregroundStyle(isSelected ? AppColor.btnText : AppColor.textPrim)
            .background(
                Capsule().fill(isSelected ? AppColor.green : AppColor.card)
            )
            .overlay(
				Capsule()
					.stroke(isSelected ? .clear : AppColor.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}


struct MedsyChipsRow<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: MedsySpacing.xs) {
                content
            }
        }
    }
}

