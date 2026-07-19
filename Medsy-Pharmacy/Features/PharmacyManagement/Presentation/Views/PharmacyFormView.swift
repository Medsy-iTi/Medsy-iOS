//
//  PharmacyFormView.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

import SwiftUI

struct PharmacyFormView: View {
    let mode: PharmacyFormMode
    @Binding var draft: PharmacyFormDraft
    var validationMessage: String?
    var isSubmitting = false
    let onBack: () -> Void
    let onSelectLicense: () -> Void
    let onSelectLocation: () -> Void
    let onSubmit: () -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: PharmacySpacing.lg) {
                PharmacyManagementHeader(
                    title: title,
                    subtitle: subtitle,
                    onBack: onBack
                )

                VStack(spacing: PharmacySpacing.sm) {
                    PharmacyAuthTextField(
                        title: "pharmacy.management.form.name".localized,
                        kind: .name,
                        text: $draft.name
                    )

                    PharmacyAuthTextField(
                        title: "pharmacy.management.form.phone".localized,
                        kind: .phone,
                        text: $draft.phoneNumber
                    )

                    PharmacyAuthTextField(
                        title: "pharmacy.management.form.address".localized,
                        kind: .address,
                        text: $draft.address
                    )
                }

                sectionTitle("pharmacy.management.form.location.title".localized)
                PharmacyLocationSelectionCard(
                    latitude: draft.latitude,
                    longitude: draft.longitude,
                    onSelect: onSelectLocation
                )

                if mode == .create {
                    sectionTitle("pharmacy.management.form.license.title".localized)
                    PharmacyLicenseSelectionCard(
                        fileName: draft.licenseFileName,
                        onSelect: onSelectLicense
                    )
                }

                PharmacyAuthValidationMessage(message: validationMessage)

                PharmacyPrimaryButton(
                    title: submitTitle,
                    systemImage: mode == .create ? "plus" : "checkmark",
                    isLoading: isSubmitting,
                    action: onSubmit
                )
            }
            .padding(.horizontal, PharmacySpacing.md)
            .padding(.top, PharmacySpacing.md)
            .padding(.bottom, PharmacySpacing.xl)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(PharmacyColor.bg.ignoresSafeArea())
    }

    private var title: String {
        mode == .create
            ? "pharmacy.management.form.create.title".localized
            : "pharmacy.management.form.edit.title".localized
    }

    private var subtitle: String {
        mode == .create
            ? "pharmacy.management.form.create.subtitle".localized
            : "pharmacy.management.form.edit.subtitle".localized
    }

    private var submitTitle: String {
        mode == .create
            ? "pharmacy.management.form.create.action".localized
            : "pharmacy.management.form.edit.action".localized
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(PharmacyColor.sans(14, .bold))
            .foregroundStyle(PharmacyColor.textPrimary)
    }
}

#Preview("Create pharmacy") {
    PharmacyFormView(
        mode: .create,
        draft: .constant(PharmacyFormDraft()),
        onBack: {},
        onSelectLicense: {},
        onSelectLocation: {},
        onSubmit: {}
    )
    .environment(LanguageManager.shared)
    .pharmacyLocalizedEnvironment()
}
