//
//  CartPrescriptionAttachmentView.swift
//  Medsy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

import SwiftUI
import UIKit

struct CartPrescriptionAttachmentView: View {
    @State private var showsRemovalConfirmation = false

    let attachment: CartPrescriptionAttachment
    let onChange: () -> Void
    let onRemove: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: MedsySpacing.md) {
            HStack {
                Label("cart.prescription.title".localized, systemImage: "doc.text.image")
                    .font(MedsyFont.title(17))
                    .foregroundStyle(AppColor.textPrim)

                Spacer()

                Button {
                    showsRemovalConfirmation = true
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(AppColor.danger)
                        .frame(width: 38, height: 38)
                        .background(AppColor.danger.opacity(0.1))
                        .clipShape(Circle())
                }
                .accessibilityLabel("cart.prescription.remove".localized)
            }

            if let image = UIImage(data: attachment.imageData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.md, style: .continuous))
                    .clipped()
            }

            Button(action: onChange) {
                Label("cart.prescription.change".localized, systemImage: "arrow.triangle.2.circlepath")
                    .font(MedsyFont.button(14))
                    .foregroundStyle(AppColor.green)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(AppColor.pill)
                    .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.md, style: .continuous))
            }
        }
        .padding(MedsySpacing.md)
        .background(AppColor.card)
        .overlay(
            RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous)
                .stroke(AppColor.border, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous))
        .alert("cart.prescription.remove_confirmation.title".localized, isPresented: $showsRemovalConfirmation) {
            Button("common.cancel".localized, role: .cancel) {}
            Button("cart.remove_confirmation.action".localized, role: .destructive, action: onRemove)
        } message: {
            Text("cart.prescription.remove_confirmation.message".localized)
        }
    }
}
