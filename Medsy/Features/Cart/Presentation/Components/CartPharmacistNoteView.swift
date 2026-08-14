//
//  CartPharmacistNoteView.swift
//  Medsy
//
//  Created by Ahmed Elkady on 12/08/2026.
//

import SwiftUI

struct CartPharmacistNoteView: View {
    let note: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: MedsySpacing.sm) {
                Image(systemName: "bubble.left")
                    .foregroundStyle(AppColor.green)

                VStack(alignment: .leading, spacing: 3) {
                    Text(note.isEmpty ? "cart.note.add".localized : "cart.note.edit".localized)
                        .font(MedsyFont.bodyMedium(15))
                        .foregroundStyle(AppColor.green)

                    if !note.isEmpty {
                        Text(note)
                            .font(MedsyFont.caption(12))
                            .foregroundStyle(AppColor.textSec)
                            .lineLimit(2)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.forward")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppColor.textSec)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(AppColor.card)
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(AppColor.green.opacity(0.45), lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
