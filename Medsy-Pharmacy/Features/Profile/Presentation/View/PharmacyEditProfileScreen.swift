//
//  PharmacyEditProfileScreen.swift
//  Medsy-Pharmacy
//

import SwiftUI

struct PharmacyEditProfileScreen: View {

    let name: String
    let phoneNumber: String
    let email: String
    let isSaving: Bool
    let errorMessage: String?
    let onCancel: () -> Void
    let onSave: (String?, Date?) async -> Bool

    @State private var draftAddress: String
    @State private var includesDateOfBirth: Bool
    @State private var draftDateOfBirth: Date
    @State private var addressError: String?

    init(
        name: String,
        phoneNumber: String,
        email: String,
        homeAddress: String,
        dateOfBirth: Date?,
        isSaving: Bool = false,
        errorMessage: String? = nil,
        onCancel: @escaping () -> Void = {},
        onSave: @escaping (String?, Date?) async -> Bool = { _, _ in true }
    ) {
        self.name = name
        self.phoneNumber = phoneNumber
        self.email = email
        self.isSaving = isSaving
        self.errorMessage = errorMessage
        self.onCancel = onCancel
        self.onSave = onSave
        _draftAddress = State(initialValue: homeAddress)
        _includesDateOfBirth = State(initialValue: dateOfBirth != nil)
        _draftDateOfBirth = State(initialValue: dateOfBirth ?? PharmacyEditProfileScreen.defaultDateOfBirth)
    }

    var body: some View {
        ZStack {
            PharmacyColor.bg
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView(showsIndicators: false) {
                    VStack(spacing: PharmacySpacing.lg) {
                        avatarBlock
                        readonlyField(titleKey: "profile.full_name", value: name, iconName: "person")
                        readonlyField(titleKey: "profile.email", value: email.isEmpty ? "profile.not_set".localized : email, iconName: "envelope")
                        readonlyField(titleKey: "profile.phone", value: phoneNumber.isEmpty ? "profile.not_set".localized : phoneNumber, iconName: "phone", noteKey: "profile.phone_support_note")
                        addressField
                        dateOfBirthField
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
            Button {
                onCancel()
            } label: {
                Image(systemName: "chevron.backward")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(PharmacyColor.textPrimary)
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.plain)

            Text("profile.edit.title".localized)
                .font(PharmacyColor.sans(17, .bold))
                .foregroundStyle(PharmacyColor.textPrimary)
                .frame(maxWidth: .infinity)

            Color.clear
                .frame(width: 36, height: 36)
        }
        .padding(.horizontal, PharmacySpacing.md)
        .padding(.vertical, PharmacySpacing.sm)
    }

    private var avatarBlock: some View {
        VStack(spacing: PharmacySpacing.sm) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .foregroundStyle(PharmacyColor.primary)
                .frame(width: 80, height: 80)
                .background(Circle().fill(PharmacyColor.surface))
                .overlay(alignment: .bottomTrailing) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(.white)
                        .padding(6)
                        .background(PharmacyColor.primary)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(PharmacyColor.surface, lineWidth: 2))
                        .offset(x: -2, y: -2)
                }

            Button("profile.change_photo".localized) {}
                .font(PharmacyColor.sans(12, .semibold))
                .foregroundStyle(PharmacyColor.primary)
                .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
    }

    private func readonlyField(titleKey: String, value: String, iconName: String, noteKey: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(titleKey.localized)
                .font(PharmacyColor.sans(13, .semibold))
                .foregroundStyle(PharmacyColor.textPrimary)

            HStack(spacing: 10) {
                Image(systemName: iconName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(PharmacyColor.textSecondary)

                Text(value)
                    .font(PharmacyColor.sans(15, .medium))
                    .foregroundStyle(PharmacyColor.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)

                Spacer(minLength: 8)

                Image(systemName: "lock.fill")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(PharmacyColor.textSecondary.opacity(0.75))
            }
            .padding(.horizontal, 17)
            .frame(height: 51)
            .background(PharmacyColor.card)
            .clipShape(RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous)
                    .stroke(PharmacyColor.border, lineWidth: 1)
            }

            if let noteKey {
                Text(noteKey.localized)
                    .font(PharmacyColor.sans(11, .medium))
                    .foregroundStyle(PharmacyColor.textSecondary)
                    .padding(.horizontal, 4)
            }
        }
    }

    private var addressField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("profile.home_address".localized)
                .font(PharmacyColor.sans(13, .semibold))
                .foregroundStyle(PharmacyColor.textPrimary)

            TextField("profile.home_address.placeholder".localized, text: $draftAddress, axis: .vertical)
                .font(PharmacyColor.sans(15, .medium))
                .foregroundStyle(PharmacyColor.textPrimary)
                .textInputAutocapitalization(.words)
                .lineLimit(2...4)
                .padding(.horizontal, 17)
                .padding(.vertical, 14)
                .background(PharmacyColor.card)
                .clipShape(RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous)
                        .stroke(addressError == nil ? PharmacyColor.border : PharmacyColor.danger, lineWidth: 1)
                }
                .onChange(of: draftAddress) {
                    addressError = nil
                }

            if let addressError {
                Text(addressError)
                    .font(PharmacyColor.sans(11, .medium))
                    .foregroundStyle(PharmacyColor.danger)
            }
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
                .background(PharmacyColor.card)
                .clipShape(RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous)
                        .stroke(PharmacyColor.border, lineWidth: 1)
                }
            }
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
                    ProgressView()
                        .tint(.white)
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
        .buttonStyle(.plain)
        .disabled(isSaving)
        .padding(.top, 8)
    }

    private func save() {
        let trimmedAddress = draftAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedAddress.isEmpty || trimmedAddress.count >= 4 else {
            addressError = "profile.address_error".localized
            return
        }

        Task {
            let success = await onSave(trimmedAddress.isEmpty ? nil : trimmedAddress, includesDateOfBirth ? draftDateOfBirth : nil)
            if success {
                onCancel()
            }
        }
    }

    private static var defaultDateOfBirth: Date {
        Calendar.current.date(from: DateComponents(year: 1995, month: 1, day: 1)) ?? Date()
    }
}
