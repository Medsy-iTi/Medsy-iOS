//
//  PrescriptionViews.swift
//  Medsy
//
//  Created by Codex on 16/07/2026.
//

import SwiftUI

struct PrescriptionUploadView: View {
    let onCamera: () -> Void
    let onGallery: () -> Void
    var body: some View { PrescriptionPage(title: "prescription.upload.title".localized) { ScrollView { VStack(spacing: MedsySpacing.lg) { VStack(spacing: MedsySpacing.sm) { Image(systemName: "doc.viewfinder").font(.system(size: 72)).foregroundStyle(AppColor.green).frame(width: 150, height: 150).background(AppColor.lightGreen, in: Circle()); Text("prescription.upload.heading".localized).font(.title2.weight(.bold)); Text("prescription.upload.message".localized).font(.body).foregroundStyle(AppColor.textSec).multilineTextAlignment(.center) }.padding(.horizontal, MedsySpacing.xl); PrescriptionOptionCard(icon: "camera.fill", title: "prescription.camera.title".localized, subtitle: "prescription.camera.message".localized, action: onCamera); PrescriptionOptionCard(icon: "photo.on.rectangle", title: "prescription.gallery.title".localized, subtitle: "prescription.gallery.message".localized, action: onGallery); PrescriptionTipsView() }.padding() } } }

struct PrescriptionPreviewView: View {
    let onContinue: () -> Void
    let onChangeImage: () -> Void
    let onDelete: () -> Void
    var body: some View { PrescriptionPage(title: "prescription.preview.title".localized) { VStack(spacing: MedsySpacing.lg) { RoundedRectangle(cornerRadius: MedsyRadius.lg).fill(Color(hex: "#EEF3F1")).frame(height: 310).overlay(VStack(spacing: MedsySpacing.sm) { Image(systemName: "doc.text.image").font(.system(size: 70)).foregroundStyle(AppColor.green); Text("prescription.preview.selected".localized).font(.subheadline.weight(.semibold)).foregroundStyle(AppColor.textSec) }); HStack { Button("prescription.change".localized, action: onChangeImage); Spacer(); Button("common.delete".localized, role: .destructive, action: onDelete) }.font(.body.weight(.semibold)); Spacer(); PrimaryButton(title: "prescription.continue".localized, action: onContinue) }.padding() } }

struct PrescriptionReadingView: View {
    let onCancel: () -> Void
    var body: some View { PrescriptionPage(title: "prescription.reading.title".localized) { VStack(spacing: MedsySpacing.xl) { ProgressView().controlSize(.large).tint(AppColor.green); VStack(spacing: MedsySpacing.xs) { Text("prescription.reading.heading".localized).font(.title3.weight(.bold)); Text("prescription.reading.message".localized).font(.body).foregroundStyle(AppColor.textSec).multilineTextAlignment(.center) }; VStack(alignment: .leading, spacing: MedsySpacing.md) { Text("prescription.reading.stages".localized).font(.headline); Label("prescription.reading.uploaded".localized, systemImage: "checkmark.circle.fill").foregroundStyle(AppColor.successGreen); Label("prescription.reading.analysed".localized, systemImage: "checkmark.circle.fill").foregroundStyle(AppColor.successGreen); Label("prescription.reading.extracting".localized, systemImage: "circle.dotted").foregroundStyle(AppColor.textSec) }.frame(maxWidth: .infinity, alignment: .leading).padding().background(AppColor.card, in: RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous)); Button("common.cancel".localized, action: onCancel).foregroundStyle(AppColor.green) }.padding(.horizontal, MedsySpacing.xl).padding(.top, 72) } }

struct PrescriptionReviewView: View {
    let medicines: [PrescriptionMedicineDisplay]
    let onAddToCart: () -> Void
    var body: some View { PrescriptionPage(title: "prescription.review.title".localized) { VStack(spacing: MedsySpacing.md) { VStack(spacing: MedsySpacing.xs) { Text("prescription.review.message".localized).font(.body).foregroundStyle(AppColor.textSec); HStack { PrescriptionCount(value: "4", title: "prescription.review.found".localized); PrescriptionCount(value: "3", title: "prescription.review.identified".localized); PrescriptionCount(value: "1", title: "prescription.review.needsReview".localized) } }.padding(.horizontal); ScrollView { LazyVStack(spacing: MedsySpacing.sm) { ForEach(medicines) { PrescriptionMedicineRow(medicine: $0) } }.padding(.horizontal) }; PrimaryButton(title: "prescription.review.addToCart".localized, action: onAddToCart).padding() } } }

struct PrescriptionResultView: View {
    enum Result { case added, uploadFailed, readingFailed, noMedicines }
    let result: Result
    let primaryAction: () -> Void
    let secondaryAction: () -> Void
    var body: some View { let content: (String, String, String, String, String) = switch result { case .added: ("checkmark", "prescription.added.title", "prescription.added.message", "prescription.added.cart", "prescription.added.home"); case .uploadFailed: ("wifi.exclamationmark", "prescription.uploadFailed.title", "prescription.uploadFailed.message", "prescription.retry", "prescription.change"); case .readingFailed: ("doc.text.magnifyingglass", "prescription.readingFailed.title", "prescription.readingFailed.message", "prescription.change", "prescription.readingFailed.continue"); case .noMedicines: ("pills", "prescription.none.title", "prescription.none.message", "prescription.change", "prescription.none.manual") }; return PrescriptionPage(title: "prescription.review.title".localized) { PrescriptionEmptyState(icon: content.0, title: content.1.localized, message: content.2.localized, primaryTitle: content.3.localized, primaryAction: primaryAction, secondaryTitle: content.4.localized, secondaryAction: secondaryAction) } }

private struct PrescriptionPage<Content: View>: View { let title: String; let content: Content; init(title: String, @ViewBuilder content: () -> Content) { self.title = title; self.content = content() }; var body: some View { content.navigationTitle(title).navigationBarTitleDisplayMode(.inline).background(AppColor.bg).toolbarBackground(AppColor.bg, for: .navigationBar) } }
private struct PrescriptionTipsView: View { var body: some View { VStack(alignment: .leading, spacing: MedsySpacing.sm) { Text("prescription.tips.title".localized).font(.headline); Label("prescription.tips.clear".localized, systemImage: "checkmark.circle"); Label("prescription.tips.shadows".localized, systemImage: "checkmark.circle"); Label("prescription.tips.full".localized, systemImage: "checkmark.circle") }.frame(maxWidth: .infinity, alignment: .leading).padding().background(AppColor.lightGreen.opacity(0.55), in: RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous)) } }
private struct PrescriptionCount: View { let value: String; let title: String; var body: some View { VStack(spacing: 2) { Text(value).font(.title3.weight(.bold)).foregroundStyle(AppColor.green); Text(title).font(.caption).foregroundStyle(AppColor.textSec) }.frame(maxWidth: .infinity).padding(.vertical, MedsySpacing.sm).background(AppColor.card, in: RoundedRectangle(cornerRadius: MedsyRadius.md, style: .continuous)) } }
