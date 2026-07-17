//
//  PharmacyLicenseUploadView.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

import SwiftUI
import UniformTypeIdentifiers

struct PharmacyLicenseUploadView: View {
    @Binding var document: PharmacyLicenseDocument?
    let isLoading: Bool
    let submissionMessage: String?
    let onContinue: (PharmacyLicenseDocument) -> Void
    @State private var isImporterPresented = false
    @State private var selectionMessage: String?

    var body: some View {
        PharmacyAuthScreenContainer {
            PharmacyAuthHeader(
                title: "pharmacy.auth.license.title".localized,
                subtitle: "pharmacy.auth.license.subtitle".localized,
                systemImage: "doc.text.fill"
            )

            requirementsCard

            if let document {
                selectedDocumentCard(document)
            } else {
                documentPickerButton
            }

            PharmacyAuthValidationMessage(message: selectionMessage ?? submissionMessage)

            PharmacyPrimaryButton(
                title: "pharmacy.auth.license.action".localized,
                isLoading: isLoading,
                isDisabled: document == nil,
                action: submit
            )
        }
        .navigationTitle("pharmacy.auth.license.navigation_title".localized)
        .navigationBarTitleDisplayMode(.inline)
        .fileImporter(
            isPresented: $isImporterPresented,
            allowedContentTypes: [.pdf],
            allowsMultipleSelection: false,
            onCompletion: selectDocument
        )
    }

    private var requirementsCard: some View {
        HStack(alignment: .top, spacing: PharmacySpacing.sm) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(PharmacyColor.primary)

            VStack(alignment: .leading, spacing: PharmacySpacing.xs) {
                Text("pharmacy.auth.license.requirements.title".localized)
                    .font(PharmacyColor.sans(14, .bold))
                    .foregroundStyle(PharmacyColor.textPrimary)

                Text("pharmacy.auth.license.requirements.description".localized)
                    .font(PharmacyColor.sans(13))
                    .foregroundStyle(PharmacyColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(PharmacySpacing.md)
        .background(PharmacyColor.primarySoft, in: RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous))
    }

    private var documentPickerButton: some View {
        Button {
            isImporterPresented = true
        } label: {
            VStack(spacing: PharmacySpacing.md) {
                Image(systemName: "arrow.up.doc.fill")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(PharmacyColor.primary)
                    .frame(width: 60, height: 60)
                    .background(PharmacyColor.primarySoft, in: Circle())

                VStack(spacing: PharmacySpacing.xxs) {
                    Text("pharmacy.auth.license.picker.title".localized)
                        .font(PharmacyColor.sans(16, .bold))
                        .foregroundStyle(PharmacyColor.textPrimary)

                    Text("pharmacy.auth.license.picker.subtitle".localized)
                        .font(PharmacyColor.sans(13))
                        .foregroundStyle(PharmacyColor.textSecondary)
                }
            }
            .padding(.vertical, 32)
            .frame(maxWidth: .infinity)
            .background(PharmacyColor.card, in: RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous)
                    .stroke(
                        PharmacyColor.primary,
                        style: StrokeStyle(lineWidth: 1.5, dash: [7, 6])
                    )
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("pharmacy.auth.license.picker.title".localized)
    }

    private func selectedDocumentCard(_ document: PharmacyLicenseDocument) -> some View {
        HStack(spacing: PharmacySpacing.md) {
            Image(systemName: "doc.fill")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 48, height: 48)
                .background(PharmacyColor.primary, in: RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous))

            VStack(alignment: .leading, spacing: PharmacySpacing.xxs) {
                Text(document.name)
                    .font(PharmacyColor.sans(14, .semibold))
                    .foregroundStyle(PharmacyColor.textPrimary)
                    .lineLimit(1)

                Text("pharmacy.auth.license.selected_size".localized(document.formattedSize))
                    .font(PharmacyColor.sans(12))
                    .foregroundStyle(PharmacyColor.textSecondary)
            }

            Spacer(minLength: PharmacySpacing.xs)

            Button {
                self.document = nil
                selectionMessage = nil
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(PharmacyColor.danger)
                    .frame(width: 40, height: 40)
                    .background(PharmacyColor.danger.opacity(0.1), in: Circle())
            }
            .accessibilityLabel("pharmacy.auth.license.remove".localized)
        }
        .padding(PharmacySpacing.md)
        .background(PharmacyColor.card, in: RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous)
                .stroke(PharmacyColor.success, lineWidth: 1.5)
        }
    }

    private func selectDocument(_ result: Result<[URL], Error>) {
        do {
            guard let url = try result.get().first else { return }
            document = try PharmacyLicenseDocument(url: url)
            selectionMessage = nil
        } catch let error as PharmacyLicenseDocumentError {
            document = nil
            selectionMessage = error.localizedMessage
        } catch {
            document = nil
            selectionMessage = "pharmacy.auth.license.error.read".localized
        }
    }

    private func submit() {
        guard let document else { return }
        onContinue(document)
    }
}

#Preview {
    NavigationStack {
        PharmacyLicenseUploadView(
            document: .constant(nil),
            isLoading: false,
            submissionMessage: nil,
            onContinue: { _ in }
        )
    }
    .environment(LanguageManager.shared)
}
