//
//  CompleteRequestNotesView.swift
//  Medsy
//
//  Created by Ehab Salah on 25/07/2026.
//

import SwiftUI

struct CompleteRequestNotesView: View {
    @Binding var notes: String

    var body: some View {
        CompleteRequestSectionCard(
            title: "complete_request.notes.title".localized,
            systemImage: "note.text"
        ) {
            Text("complete_request.notes.subtitle".localized)
                .font(MedsyFont.caption())
                .foregroundStyle(AppColor.textSec)

            TextField(
                "complete_request.notes.placeholder".localized,
                text: $notes,
                axis: .vertical
            )
            .font(MedsyFont.body())
            .foregroundStyle(AppColor.textPrim)
            .lineLimit(3...6)
            .padding(MedsySpacing.sm)
            .background(AppColor.surface)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: MedsyRadius.md,
                    style: .continuous
                )
            )
            .overlay {
                RoundedRectangle(
                    cornerRadius: MedsyRadius.md,
                    style: .continuous
                )
                .stroke(AppColor.border, lineWidth: 1)
            }
            .accessibilityLabel("complete_request.notes.title".localized)
        }
    }
}
