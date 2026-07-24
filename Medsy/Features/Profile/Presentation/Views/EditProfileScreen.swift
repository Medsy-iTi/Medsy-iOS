//
//  EditProfileScreen.swift
//  Medsy
//
//  Created by Ahmed Elkady on 15/07/2026.
//

import SwiftUI

struct EditProfileScreen: View {

    let phoneNumber: String
    let onCancel: () -> Void
    let onSave: (String, String, String, Date?) async -> Void

    @State private var firstName: String
    @State private var lastName: String
    @State private var homeAddress: String
    @State private var dateOfBirth: Date?

    @State private var firstNameError: String?
    @State private var lastNameError: String?
    @State private var homeAddressError: String?

    @State private var isSaving = false
    @State private var showDatePicker = false

    init(
        firstName: String,
        lastName: String,
        homeAddress: String,
        dateOfBirth: Date?,
        phoneNumber: String,
        onCancel: @escaping () -> Void = {},
        onSave: @escaping (String, String, String, Date?) async -> Void = { _, _, _, _ in }
    ) {
        _firstName   = State(initialValue: firstName)
        _lastName    = State(initialValue: lastName)
        _homeAddress = State(initialValue: homeAddress)
        _dateOfBirth = State(initialValue: dateOfBirth)
        self.phoneNumber = phoneNumber
        self.onCancel    = onCancel
        self.onSave      = onSave
    }

    var body: some View {
        ZStack {
            ProfileStyle.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        avatarBlock
                        firstNameField
                        lastNameField
                        homeAddressField
                        dateOfBirthField
                        phoneBlock
                        saveButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 4)
                    .padding(.bottom, 32)
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
                    .foregroundStyle(ProfileStyle.primaryText)
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.plain)

            Text("profile.edit.title".localized)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(ProfileStyle.primaryText)
                .frame(maxWidth: .infinity)

            Color.clear
                .frame(width: 36, height: 36)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    private var avatarBlock: some View {
        VStack(spacing: 12) {
            ProfileAvatarView(size: 80, showsBadge: true)

            Button("profile.change_photo".localized) {}
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(ProfileStyle.green)
                .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
    }

    private var firstNameField: some View {
        editField(
            labelKey: "profile.first_name",
            placeholderKey: "profile.first_name.placeholder",
            text: $firstName,
            error: firstNameError,
            autocapitalization: .words
        ) {
            firstNameError = nil
        }
    }

    private var lastNameField: some View {
        editField(
            labelKey: "profile.last_name",
            placeholderKey: "profile.last_name.placeholder",
            text: $lastName,
            error: lastNameError,
            autocapitalization: .words
        ) {
            lastNameError = nil
        }
    }

    private var homeAddressField: some View {
        editField(
            labelKey: "profile.home_address",
            placeholderKey: "profile.home_address.placeholder",
            text: $homeAddress,
            error: homeAddressError,
            autocapitalization: .sentences
        ) {
            homeAddressError = nil
        }
    }

    private var dateOfBirthField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("profile.date_of_birth".localized)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(ProfileStyle.primaryText)

            Button {
                withAnimation(.easeInOut(duration: 0.2)) { showDatePicker.toggle() }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "calendar")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(ProfileStyle.secondaryText)

                    Text(dateOfBirth.map(formattedDate) ?? "profile.date_of_birth.placeholder".localized)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(dateOfBirth == nil ? ProfileStyle.secondaryText : ProfileStyle.primaryText)

                    Spacer(minLength: 8)

                    Image(systemName: showDatePicker ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(ProfileStyle.secondaryText)
                }
                .padding(.horizontal, 17)
                .frame(height: 51)
                .background(ProfileStyle.card)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(ProfileStyle.border, lineWidth: 1)
                }
            }
            .buttonStyle(.plain)

            if showDatePicker {
                DatePicker(
                    "",
                    selection: Binding(
                        get: { dateOfBirth ?? Date() },
                        set: { dateOfBirth = $0 }
                    ),
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .tint(ProfileStyle.green)
                .padding(.top, 4)
            }
        }
    }

    private var phoneBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("profile.phone".localized)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(ProfileStyle.primaryText)

            HStack(spacing: 10) {
                Image(systemName: "phone")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(ProfileStyle.secondaryText)

                Text(phoneNumber)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(ProfileStyle.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)

                Spacer(minLength: 8)

                Label("profile.verified".localized, systemImage: "checkmark.seal.fill")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(ProfileStyle.green)
                    .lineLimit(1)
            }
            .padding(.horizontal, 17)
            .frame(height: 51)
            .background(ProfileStyle.card)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(ProfileStyle.border, lineWidth: 1)
            }

            Text("profile.phone_support_note".localized)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(ProfileStyle.secondaryText)
                .padding(.horizontal, 4)
        }
    }

    private var saveButton: some View {
        Button {
            Task { await save() }
        } label: {
            Group {
                if isSaving {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("profile.save_changes".localized)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(ProfileStyle.green)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(isSaving)
        .padding(.top, 8)
    }

    @ViewBuilder
    private func editField(
        labelKey: String,
        placeholderKey: String,
        text: Binding<String>,
        error: String?,
        autocapitalization: TextInputAutocapitalization,
        onTextChange: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(labelKey.localized)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(ProfileStyle.primaryText)

            TextField(placeholderKey.localized, text: text)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(ProfileStyle.primaryText)
                .textInputAutocapitalization(autocapitalization)
                .padding(.horizontal, 17)
                .frame(height: 51)
                .background(ProfileStyle.card)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(error == nil ? ProfileStyle.border : ProfileStyle.red, lineWidth: 1)
                }
                .onChange(of: text.wrappedValue) { onTextChange() }

            if let error {
                Text(error)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(ProfileStyle.red)
            }
        }
    }

    private func save() async {
        let trimmedFirst   = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLast    = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAddress = homeAddress.trimmingCharacters(in: .whitespacesAndNewlines)

        var hasError = false

        if trimmedFirst.isEmpty {
            firstNameError = "profile.name_required_error".localized
            hasError = true
        }
        if trimmedLast.isEmpty {
            lastNameError = "profile.name_required_error".localized
            hasError = true
        }
        if trimmedAddress.isEmpty {
            homeAddressError = "profile.address_required_error".localized
            hasError = true
        }

        guard !hasError else { return }

        isSaving = true
        await onSave(trimmedFirst, trimmedLast, trimmedAddress, dateOfBirth)
        isSaving = false
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

#Preview {
    EditProfileScreen(
        firstName: "Ahmed",
        lastName: "Elkady",
        homeAddress: "123 Nile Street, Maadi",
        dateOfBirth: nil,
        phoneNumber: "+20 10 1234 5678"
    )
    .environment(LanguageManager.shared)
}
