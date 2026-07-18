//
//  PrescriptionViews.swift
//  Medsy
//
//  Created by Ahmed Elkady on 16/07/2026.
//

import SwiftUI
import UIKit

struct PrescriptionUploadView: View {
    let onCamera: () -> Void
    let onGallery: () -> Void
    let onBack: (() -> Void)?

    init(onCamera: @escaping () -> Void, onGallery: @escaping () -> Void, onBack: (() -> Void)? = nil) {
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

                        Text("prescription.upload.heading".localized)
                            .font(.title2.weight(.bold))

                        Text("prescription.upload.message".localized)
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

struct PrescriptionPreviewView: View {
    let imageData: Data?
    let onContinue: () -> Void
    let onChangeImage: () -> Void
    let onDelete: () -> Void
    let onBack: () -> Void

    var body: some View {
        PrescriptionPage(title: "prescription.preview.title".localized, onBack: onBack) {
            VStack(spacing: MedsySpacing.lg) {
                prescriptionImage

                HStack {
                    Button("prescription.change".localized, action: onChangeImage)
                    Spacer()
                    Button("common.delete".localized, role: .destructive, action: onDelete)
                }
                .font(.body.weight(.semibold))

                Spacer()

                PrimaryButton(title: "prescription.continue".localized, action: onContinue)
            }
            .padding()
        }
    }

    @ViewBuilder
    private var prescriptionImage: some View {
        if let imageData, let image = UIImage(data: imageData) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: 420)
                .background(AppColor.card)
                .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.lg))
                .overlay(
                    RoundedRectangle(cornerRadius: MedsyRadius.lg)
                        .stroke(AppColor.border)
                )
        } else {
            RoundedRectangle(cornerRadius: MedsyRadius.lg)
                .fill(AppColor.card)
                .frame(height: 310)
                .overlay {
                    Image(systemName: "doc.text.image")
                        .font(.system(size: 70))
                        .foregroundStyle(AppColor.green)
                }
        }
    }
}

struct PrescriptionReadingView: View {
    let stage: PrescriptionReadingStage
    let onCancel: () -> Void

    var body: some View {
        PrescriptionPage(title: "prescription.reading.title".localized, onBack: onCancel) {
            VStack(spacing: MedsySpacing.xl) {
                ProgressView()
                    .controlSize(.large)
                    .tint(AppColor.green)

                VStack(spacing: MedsySpacing.xs) {
                    Text("prescription.reading.heading".localized)
                        .font(.title3.weight(.bold))

                    Text("prescription.reading.message".localized)
                        .font(.body)
                        .foregroundStyle(AppColor.textSec)
                        .multilineTextAlignment(.center)
                }

                VStack(alignment: .leading, spacing: MedsySpacing.md) {
                    Text("prescription.reading.stages".localized)
                        .font(.headline)

                    PrescriptionReadingStageRow(
                        title: "prescription.reading.uploaded".localized,
                        rowStage: .uploading,
                        currentStage: stage
                    )

                    PrescriptionReadingStageRow(
                        title: "prescription.reading.analysed".localized,
                        rowStage: .analysing,
                        currentStage: stage
                    )

                    PrescriptionReadingStageRow(
                        title: "prescription.reading.extracting".localized,
                        rowStage: .extracting,
                        currentStage: stage
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(AppColor.card, in: RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous))

                Button("common.cancel".localized, action: onCancel)
                    .foregroundStyle(AppColor.green)
            }
            .padding(.horizontal, MedsySpacing.xl)
            .padding(.top, 72)
            .animation(.easeInOut(duration: 0.3), value: stage)
        }
    }
}

private struct PrescriptionReadingStageRow: View {
    let title: String
    let rowStage: PrescriptionReadingStage
    let currentStage: PrescriptionReadingStage

    private var isCompleted: Bool {
        rowStage.rawValue < currentStage.rawValue
    }

    private var isActive: Bool {
        rowStage == currentStage
    }

    var body: some View {
        HStack(spacing: MedsySpacing.sm) {
            Group {
                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(AppColor.successGreen)
                        .transition(.scale.combined(with: .opacity))
                } else if isActive {
                    ProgressView()
                        .tint(AppColor.green)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Image(systemName: "circle")
                        .foregroundStyle(AppColor.textSec.opacity(0.45))
                }
            }
            .frame(width: 24, height: 24)

            Text(title)
                .foregroundStyle(isCompleted || isActive ? AppColor.textPrim : AppColor.textSec)

            Spacer()
        }
    }
}

struct PrescriptionReviewView: View {
    let medicines: [PrescriptionMedicineDisplay]
    let confirmedCount: Int
    let canAddToCart: Bool
    let onConfirm: (UUID) -> Void
    let onChooseAlternative: (UUID) -> Void
    let onAddToCart: () -> Void
    let onBack: () -> Void

    var body: some View {
        PrescriptionPage(title: "prescription.review.title".localized, onBack: onBack) {
            VStack(spacing: MedsySpacing.md) {
                VStack(spacing: MedsySpacing.xs) {
                    Text("prescription.review.message".localized)
                        .font(.body)
                        .foregroundStyle(AppColor.textSec)

                    HStack {
                        PrescriptionCount(value: "\(medicines.count)", title: "prescription.review.found".localized)
                        PrescriptionCount(value: "\(confirmedCount)", title: "prescription.review.confirmed".localized)
                        PrescriptionCount(
                            value: "\(medicines.filter { $0.needsReview && !$0.isConfirmed }.count)",
                            title: "prescription.review.needsReview".localized
                        )
                    }
                }
                .padding(.horizontal)

                ScrollView {
                    LazyVStack(spacing: MedsySpacing.sm) {
                        ForEach(medicines) { medicine in
                            PrescriptionMedicineRow(
                                medicine: medicine,
                                onConfirm: { onConfirm(medicine.id) },
                                onChooseAlternative: { onChooseAlternative(medicine.id) }
                            )
                        }
                    }
                    .padding(.horizontal)
                }

                PrimaryButton(
                    title: "prescription.review.addToCart".localized,
                    isDisabled: !canAddToCart,
                    action: onAddToCart
                )
                    .padding()
            }
        }
    }
}

struct PrescriptionResultView: View {
    let result: PrescriptionFlowResult
    let primaryAction: () -> Void
    let secondaryAction: () -> Void
    let isPrimaryDisabled: Bool
    let onBack: () -> Void

    var body: some View {
        PrescriptionPage(title: "prescription.review.title".localized, onBack: onBack) {
            PrescriptionEmptyState(
                icon: content.icon,
                title: content.title.localized,
                message: content.message.localized,
                primaryTitle: content.primaryTitle.localized,
                primaryAction: primaryAction,
                isPrimaryDisabled: isPrimaryDisabled,
                secondaryTitle: content.secondaryTitle.localized,
                secondaryAction: secondaryAction
            )
        }
    }

    private var content: (icon: String, title: String, message: String, primaryTitle: String, secondaryTitle: String) {
        switch result {
        case .added:
            ("checkmark", "prescription.added.title", "prescription.added.message", "prescription.added.cart", "prescription.added.home")
        case .uploadFailed:
            ("wifi.exclamationmark", "prescription.uploadFailed.title", "prescription.uploadFailed.message", "prescription.retry", "prescription.change")
        case .readingFailed:
            ("doc.text.magnifyingglass", "prescription.readingFailed.title", "prescription.readingFailed.message", "prescription.change", "prescription.readingFailed.continue")
        case .noMedicines:
            ("pills", "prescription.none.title", "prescription.none.message", "prescription.change", "prescription.none.manual")
        }
    }
}

private struct PrescriptionPage<Content: View>: View {
    let title: String
    let onBack: (() -> Void)?
    let content: Content

    init(title: String, onBack: (() -> Void)? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.onBack = onBack
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            MedsyNavBar(title: title, onBack: onBack) {
                EmptyView()
            }
            content
        }
        .background(AppColor.bg)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarHidden(true)
    }
}

private struct PrescriptionTipsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: MedsySpacing.sm) {
            Text("prescription.tips.title".localized)
                .font(.headline)

            Label("prescription.tips.clear".localized, systemImage: "checkmark.circle")
            Label("prescription.tips.shadows".localized, systemImage: "checkmark.circle")
            Label("prescription.tips.full".localized, systemImage: "checkmark.circle")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(AppColor.lightGreen.opacity(0.55), in: RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous))
    }
}

private struct PrescriptionCount: View {
    let value: String
    let title: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(AppColor.green)

            Text(title)
                .font(.caption)
                .foregroundStyle(AppColor.textSec)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, MedsySpacing.sm)
        .background(AppColor.card, in: RoundedRectangle(cornerRadius: MedsyRadius.md, style: .continuous))
    }
}
