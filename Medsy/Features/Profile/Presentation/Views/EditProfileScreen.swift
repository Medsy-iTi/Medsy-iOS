//
//  EditProfileScreen.swift
//  Medsy
//
//  Created by Ahmed Elkady on 15/07/2026.
//

import SwiftUI
import MapKit

struct EditProfileScreen: View {
    let firstName: String
    let lastName: String
    let phoneNumber: String
    let email: String
    let isSaving: Bool
    let errorMessage: String?
    let onCancel: () -> Void
    let onSave: (String, String, String?, Double?, Double?, Date?) async -> Bool

    @State private var draftFirstName: String
    @State private var draftLastName: String
    @State private var draftAddress: String
    @State private var includesDateOfBirth: Bool
    @State private var draftDateOfBirth: Date
    @State private var firstNameError: String?
    @State private var lastNameError: String?
    @State private var addressError: String?
    @State private var showsAddressPicker = false
    @State private var pickedLatitude: Double?
    @State private var pickedLongitude: Double?

    init(
        firstName: String,
        lastName: String,
        phoneNumber: String,
        email: String,
        homeAddress: String,
        latitude: Double? = nil,
        longitude: Double? = nil,
        dateOfBirth: Date?,
        isSaving: Bool = false,
        errorMessage: String? = nil,
        onCancel: @escaping () -> Void = {},
        onSave: @escaping (String, String, String?, Double?, Double?, Date?) async -> Bool = { _, _, _, _, _, _ in true }
    ) {
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.email = email
        self.isSaving = isSaving
        self.errorMessage = errorMessage
        self.onCancel = onCancel
        self.onSave = onSave
        _draftFirstName = State(initialValue: firstName)
        _draftLastName = State(initialValue: lastName)
        _draftAddress = State(initialValue: homeAddress)
        _includesDateOfBirth = State(initialValue: dateOfBirth != nil)
        _draftDateOfBirth = State(initialValue: dateOfBirth ?? EditProfileScreen.defaultDateOfBirth)
        _pickedLatitude = State(initialValue: latitude)
        _pickedLongitude = State(initialValue: longitude)
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
                        readonlyField(titleKey: "profile.email", value: email.isEmpty ? "profile.not_set".localized : email, iconName: "envelope")
                        readonlyField(titleKey: "profile.phone", value: phoneNumber.isEmpty ? "profile.not_set".localized : phoneNumber, iconName: "phone", noteKey: "profile.phone_support_note")
                        addressField
                        dateOfBirthField
                        errorBlock
                        saveButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 4)
                    .padding(.bottom, 32)
                }
            }
        }
        .sheet(isPresented: $showsAddressPicker) {
            let viewModel = AddressPickerViewModel(
                initialAddress: draftAddress,
                initialCoordinate: pickedLatitude.map { lat in
                    CLLocationCoordinate2D(latitude: lat, longitude: pickedLongitude ?? 0)
                },
                searchAddressUseCase: DIContainer.shared.resolve(SearchAddressUseCaseProtocol.self),
                reverseGeocodeAddressUseCase: DIContainer.shared.resolve(ReverseGeocodeAddressUseCaseProtocol.self),
                onConfirm: { address, latitude, longitude in
                    draftAddress = address
                    pickedLatitude = latitude
                    pickedLongitude = longitude
                    showsAddressPicker = false
                },
                onCancel: {
                    showsAddressPicker = false
                }
            )

            AddressPickerScreen(viewModel: viewModel)
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
            text: $draftFirstName,
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
            text: $draftLastName,
            error: lastNameError,
            autocapitalization: .words
        ) {
            lastNameError = nil
        }
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

    private func readonlyField(titleKey: String, value: String, iconName: String, noteKey: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(titleKey.localized)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(ProfileStyle.primaryText)

            HStack(spacing: 10) {
                Image(systemName: iconName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(ProfileStyle.secondaryText)

                Text(value)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(ProfileStyle.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)

                Spacer(minLength: 8)

                Image(systemName: "lock.fill")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(ProfileStyle.secondaryText.opacity(0.75))
            }
            .padding(.horizontal, 17)
            .frame(height: 51)
            .background(ProfileStyle.card)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(ProfileStyle.border, lineWidth: 1)
            }

            if let noteKey {
                Text(noteKey.localized)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(ProfileStyle.secondaryText)
                    .padding(.horizontal, 4)
            }
        }
    }

    private var addressField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("profile.home_address".localized)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(ProfileStyle.primaryText)

            TextField("profile.home_address.placeholder".localized, text: $draftAddress, axis: .vertical)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(ProfileStyle.primaryText)
                .textInputAutocapitalization(.words)
                .lineLimit(2...4)
                .padding(.horizontal, 17)
                .padding(.vertical, 14)
                .background(ProfileStyle.card)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(addressError == nil ? ProfileStyle.border : ProfileStyle.red, lineWidth: 1)
                }
                .onChange(of: draftAddress) {
                    addressError = nil
                }

            Button {
                showsAddressPicker = true
            } label: {
                Label("profile.pick_on_map".localized, systemImage: "mappin.and.ellipse")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(ProfileStyle.green)
            }
            .buttonStyle(.plain)

            if let addressError {
                Text(addressError)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(ProfileStyle.red)
            }
        }
    }

    private var dateOfBirthField: some View {
        VStack(alignment: .leading, spacing: 10) {
            Toggle(isOn: $includesDateOfBirth) {
                Text("profile.date_of_birth".localized)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(ProfileStyle.primaryText)
            }
            .tint(ProfileStyle.green)

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
                .background(ProfileStyle.card)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(ProfileStyle.border, lineWidth: 1)
                }
            }
        }
    }

    @ViewBuilder
    private var errorBlock: some View {
        if let errorMessage {
            Text(errorMessage)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(ProfileStyle.red)
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
                        .font(.system(size: 15, weight: .bold))
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(isSaving ? ProfileStyle.green.opacity(0.72) : ProfileStyle.green)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(isSaving)
        .padding(.top, 8)
    }

    private func save() {
        let trimmedFirst = draftFirstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLast = draftLastName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAddress = draftAddress.trimmingCharacters(in: .whitespacesAndNewlines)

        var hasError = false

        if trimmedFirst.isEmpty {
            firstNameError = "profile.name_required_error".localized
            hasError = true
        }

        if trimmedLast.isEmpty {
            lastNameError = "profile.name_required_error".localized
            hasError = true
        }

        if !trimmedAddress.isEmpty && trimmedAddress.count < 4 {
            addressError = "profile.address_error".localized
            hasError = true
        }

        guard !hasError else { return }

        Task {
            let success = await onSave(
                trimmedFirst,
                trimmedLast,
                trimmedAddress.isEmpty ? nil : trimmedAddress,
                trimmedAddress.isEmpty ? nil : pickedLatitude,
                trimmedAddress.isEmpty ? nil : pickedLongitude,
                includesDateOfBirth ? draftDateOfBirth : nil
            )
            if success {
                onCancel()
            }
        }
    }

    private static var defaultDateOfBirth: Date {
        Calendar.current.date(from: DateComponents(year: 1995, month: 1, day: 1)) ?? Date()
    }
}

#Preview {
    EditProfileScreen(
        firstName: "Ahmed",
        lastName: "Elkady",
        phoneNumber: "+20 10 1234 5678",
        email: "customer@dawanow.com",
        homeAddress: "Cairo, Egypt",
        dateOfBirth: Date()
    )
    .environment(LanguageManager.shared)
}
