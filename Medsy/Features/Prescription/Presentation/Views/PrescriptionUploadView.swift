//
//  PrescriptionUploadView.swift
//  Medsy
//
//  Created by Ehab Salah on 22/07/2026.
//

import SwiftUI

// MARK: - View

struct PrescriptionUploadView: View {
    let isAttachmentOnly: Bool
    let onCamera: () -> Void
    let onGallery: () -> Void
    let onBack: (() -> Void)?

    init(
        isAttachmentOnly: Bool = false,
        onCamera: @escaping () -> Void,
        onGallery: @escaping () -> Void,
        onBack: (() -> Void)? = nil
    ) {
        self.isAttachmentOnly = isAttachmentOnly
        self.onCamera = onCamera
        self.onGallery = onGallery
        self.onBack = onBack
    }

    var body: some View {
        PrescriptionPage(title: "prescription.upload.title".localized, onBack: onBack) {
            ScrollView {
                VStack(spacing: MedsySpacing.lg) {
                    VStack(spacing: MedsySpacing.sm) {
                        Image(systemName: "doc.viewfinder")
                            .font(.system(size: 72))
                            .foregroundStyle(AppColor.green)
                            .frame(width: 150, height: 150)
                            .background(AppColor.lightGreen, in: Circle())

                        Text(
                            isAttachmentOnly
                                ? "prescription.attachment.heading".localized
                                : "prescription.upload.heading".localized
                        )
                            .font(.title2.weight(.bold))

                        Text(
                            isAttachmentOnly
                                ? "prescription.attachment.message".localized
                                : "prescription.upload.message".localized
                        )
                            .font(.body)
                            .foregroundStyle(AppColor.textSec)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, MedsySpacing.xl)

                    PrescriptionOptionCard(
                        icon: "camera.fill",
                        title: "prescription.camera.title".localized,
                        subtitle: "prescription.camera.message".localized,
                        action: onCamera
                    )

                    PrescriptionOptionCard(
                        icon: "photo.on.rectangle",
                        title: "prescription.gallery.title".localized,
                        subtitle: "prescription.gallery.message".localized,
                        action: onGallery
                    )

                    PrescriptionTipsView()
                }
                .padding()
            }
        }
    }
}
