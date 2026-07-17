//
//  PharmacyAccountTypeView.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

import SwiftUI

struct PharmacyAccountTypeView: View {
    @Binding var selection: PharmacyAccountType?
    let validationMessage: String?
    let isLoading: Bool
    let onRegister: () -> Void

    var body: some View {
        PharmacyAuthScreenContainer {
            PharmacyRegistrationProgressView(currentStep: 2, totalSteps: 2)

            PharmacyAuthHeader(
                title: "pharmacy.auth.account_type.title".localized,
                subtitle: "pharmacy.auth.account_type.subtitle".localized,
                systemImage: "person.2.fill"
            )

            VStack(spacing: PharmacySpacing.sm) {
                ForEach(PharmacyAccountType.allCases) { accountType in
                    accountTypeButton(accountType)
                }
            }

            PharmacyAuthValidationMessage(message: validationMessage)

            PharmacyPrimaryButton(
                title: "pharmacy.auth.register".localized,
                isLoading: isLoading,
                isDisabled: selection == nil,
                action: onRegister
            )
        }
        .navigationTitle("pharmacy.auth.account_type.title".localized)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func accountTypeButton(_ accountType: PharmacyAccountType) -> some View {
        let isSelected = selection == accountType

        return Button {
            selection = accountType
        } label: {
            HStack(spacing: PharmacySpacing.md) {
                Image(systemName: accountType.systemImage)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(isSelected ? .white : PharmacyColor.primary)
                    .frame(width: 48, height: 48)
                    .background(
                        isSelected ? PharmacyColor.primary : PharmacyColor.primarySoft,
                        in: RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous)
                    )

                VStack(alignment: .leading, spacing: PharmacySpacing.xxs) {
                    Text(accountType.titleKey.localized)
                        .font(PharmacyColor.sans(16, .bold))
                        .foregroundStyle(PharmacyColor.textPrimary)

                    Text(accountType.descriptionKey.localized)
                        .font(PharmacyColor.sans(13))
                        .foregroundStyle(PharmacyColor.textSecondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: PharmacySpacing.xs)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(isSelected ? PharmacyColor.primary : PharmacyColor.border)
            }
            .padding(PharmacySpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(PharmacyColor.card, in: RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous)
                    .stroke(isSelected ? PharmacyColor.primary : PharmacyColor.border, lineWidth: isSelected ? 2 : 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
