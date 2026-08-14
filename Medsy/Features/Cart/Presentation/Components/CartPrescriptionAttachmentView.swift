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
        HStack(spacing: MedsySpacing.sm) {
            if let image = UIImage(data: attachment.imageData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 64, height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.sm, style: .continuous))
                    .clipped()
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("cart.prescription.title".localized)
                    .font(MedsyFont.title(15))
                    .foregroundStyle(AppColor.textPrim)

                Text("cart.prescription.local_only".localized)
                    .font(MedsyFont.body(12))
                    .foregroundStyle(AppColor.textSec)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: onChange) {
                Image(systemName: "pencil")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppColor.textPrim)
                    .frame(width: 38, height: 38)
            }
            .accessibilityLabel("cart.prescription.change".localized)

            Button {
                showsRemovalConfirmation = true
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppColor.danger)
                    .frame(width: 38, height: 38)
            }
            .accessibilityLabel("cart.prescription.remove".localized)
        }
        .padding(10)
        .background(AppColor.card)
        .overlay(
            RoundedRectangle(cornerRadius: MedsyRadius.sm, style: .continuous)
                .stroke(AppColor.border, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.sm, style: .continuous))
        .alert("cart.prescription.remove_confirmation.title".localized, isPresented: $showsRemovalConfirmation) {
            Button("common.cancel".localized, role: .cancel) {}
            Button("cart.remove_confirmation.action".localized, role: .destructive, action: onRemove)
        } message: {
            Text("cart.prescription.remove_confirmation.message".localized)
        }
    }
}
