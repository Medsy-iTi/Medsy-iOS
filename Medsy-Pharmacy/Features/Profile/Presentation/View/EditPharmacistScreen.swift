//
//  EditPharmacistScreen.swift
//  Medsy-Pharmacy
//

import SwiftUI

struct EditPharmacistScreen: View {
    let member: PharmacistMember
    let isSaving: Bool
    let errorMessage: String?
    let onCancel: () -> Void
    let onSave: (String, String, String, String?, Date?) async -> Bool

    @State private var draftEmail: String
    @State private var draftAddress: String
    @State private var includesDateOfBirth: Bool
    @State private var draftDateOfBirth: Date
    @State private var validationError: String?

    init(
        member: PharmacistMember,
        isSaving: Bool = false,
        errorMessage: String? = nil,
        onCancel: @escaping () -> Void = {},
        onSave: @escaping (String, String, String, String?, Date?) async -> Bool = { _, _, _, _, _ in true }
    ) {
        self.member = member
        self.isSaving = isSaving
        self.errorMessage = errorMessage
        self.onCancel = onCancel
        self.onSave = onSave
        _draftEmail = State(initialValue: member.email)
        _draftAddress = State(initialValue: "")
        _includesDateOfBirth = State(initialValue: false)
        _draftDateOfBirth = State(initialValue: Self.defaultDateOfBirth)
    }

    var body: some View {
        ZStack {
            PharmacyColor.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView(showsIndicators: false) {
                    VStack(spacing: PharmacySpacing.lg) {
                        readonlyField(titleKey: "profile.first_name", value: member.firstName, icon: "person")
                        readonlyField(titleKey: "profile.last_name", value: member.lastName, icon: "person")
                        editableField(titleKey: "profile.email", text: $draftEmail, icon: "envelope", keyboardType: .emailAddress)
                        editableField(titleKey: "profile.home_address", text: $draftAddress, icon: "mappin.and.ellipse", axis: .vertical)
                        dateOfBirthField
                        validationBlock
                        errorBlock
                        saveButton
                    }
                    .padding(.horizontal, PharmacySpacing.md)
                    .padding(.top, PharmacySpacing.sm)
                    .padding(.bottom, PharmacySpacing.xl)
                }
            }
        }
    }

    private var header: some View {
        HStack {
            Button(action: onCancel) {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(PharmacyColor.textPrimary)
                    .frame(width: 44, height: 44)
                    .background(PharmacyColor.surface)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(PharmacyColor.border, lineWidth: 1))
            }
            .buttonStyle(PharmacyPressableButtonStyle())

            Text("pharmacy_team.edit_title".localized)
                .font(PharmacyColor.sans(17, .bold))
                .foregroundStyle(PharmacyColor.textPrimary)
                .frame(maxWidth: .infinity)

            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.horizontal, PharmacySpacing.md)
        .padding(.vertical, PharmacySpacing.sm)
    }

    private func readonlyField(titleKey: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(titleKey.localized)
                .font(PharmacyColor.sans(13, .semibold))
                .foregroundStyle(PharmacyColor.textPrimary)

            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(PharmacyColor.textSecondary)
                    .frame(width: 24)

                Text(value)
                    .font(PharmacyColor.sans(15, .medium))
                    .foregroundStyle(PharmacyColor.textPrimary)

                Spacer()

                Image(systemName: "lock.fill")
                    .font(.caption2)
                    .foregroundStyle(PharmacyColor.textSecondary)
            }
            .padding(.horizontal, 17)
            .padding(.vertical, 14)
            .pharmacyInputSurface()
        }
    }

    private func editableField(
        titleKey: String,
        text: Binding<String>,
        icon: String,
        keyboardType: UIKeyboardType = .default,
        axis: Axis = .horizontal
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(titleKey.localized)
                .font(PharmacyColor.sans(13, .semibold))
                .foregroundStyle(PharmacyColor.textPrimary)

            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(PharmacyColor.textSecondary)

                TextField(titleKey.localized, text: text, axis: axis)
                    .font(PharmacyColor.sans(15, .medium))
                    .foregroundStyle(PharmacyColor.textPrimary)
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(keyboardType == .emailAddress ? .never : .words)
                    .autocorrectionDisabled(keyboardType == .emailAddress)
                    .lineLimit(axis == .vertical ? 4 : 1)
            }
            .padding(.horizontal, 17)
            .padding(.vertical, 14)
            .pharmacyInputSurface()
        }
    }

    private var dateOfBirthField: some View {
        VStack(alignment: .leading, spacing: 10) {
            Toggle(isOn: $includesDateOfBirth) {
                Text("profile.date_of_birth".localized)
                    .font(PharmacyColor.sans(13, .semibold))
                    .foregroundStyle(PharmacyColor.textPrimary)
            }
            .tint(PharmacyColor.primary)

            if includesDateOfBirth {
                DatePicker(
                    "profile.date_of_birth".localized,
                    selection: $draftDateOfBirth,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .labelsHidden()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 17)
                .frame(height: 51)
                .pharmacyInputSurface()
            }
        }
    }

    @ViewBuilder
    private var validationBlock: some View {
        if let validationError {
            Text(validationError)
                .font(PharmacyColor.sans(12, .medium))
                .foregroundStyle(PharmacyColor.danger)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 4)
        }
    }

    @ViewBuilder
    private var errorBlock: some View {
        if let errorMessage {
            Text(errorMessage)
                .font(PharmacyColor.sans(12, .medium))
                .foregroundStyle(PharmacyColor.danger)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 4)
        }
    }

    private var saveButton: some View {
        Button {
            save()
        } label: {
            Group {
                if isSaving {
                    ProgressView().tint(.white)
                } else {
                    Text("profile.save_changes".localized)
                        .font(PharmacyColor.sans(15, .bold))
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(isSaving ? PharmacyColor.primary.opacity(0.72) : PharmacyColor.primary)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(PharmacyPressableButtonStyle())
        .disabled(isSaving)
        .padding(.top, 8)
    }

    private func save() {
        let email = draftEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        let address = draftAddress.trimmingCharacters(in: .whitespacesAndNewlines)

        guard email.contains("@") else {
            validationError = "pharmacy_team.validation_email".localized
            return
        }

        validationError = nil

        Task {
            let success = await onSave(
                email,
                member.firstName,
                member.lastName,
                address.isEmpty ? nil : address,
                includesDateOfBirth ? draftDateOfBirth : nil
            )
            if success { onCancel() }
        }
    }

    private static var defaultDateOfBirth: Date {
        Calendar.current.date(from: DateComponents(year: 1995, month: 1, day: 1)) ?? Date()
    }
}
