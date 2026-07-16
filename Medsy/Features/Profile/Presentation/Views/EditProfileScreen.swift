//
//  EditProfileScreen.swift
//  Medsy
//
//  Created by Ahmed Elkady on 15/07/2026.
//

import SwiftUI

struct EditProfileScreen: View {

    @Binding var name: String

    let phoneNumber: String
    let onCancel: () -> Void
    let onSave: () -> Void

    @State private var draftName: String
    @State private var nameError: String?

    init(
        name: Binding<String>,
        phoneNumber: String,
        onCancel: @escaping () -> Void = {},
        onSave: @escaping () -> Void = {}
    ) {
        _name = name
        self.phoneNumber = phoneNumber
        self.onCancel = onCancel
        self.onSave = onSave
        _draftName = State(initialValue: name.wrappedValue)
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
                        nameField
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

    private var nameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("profile.full_name".localized)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(ProfileStyle.primaryText)

            TextField("profile.full_name.placeholder".localized, text: $draftName)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(ProfileStyle.primaryText)
                .textInputAutocapitalization(.words)
                .padding(.horizontal, 17)
                .frame(height: 51)
                .background(ProfileStyle.card)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(nameError == nil ? ProfileStyle.border : ProfileStyle.red, lineWidth: 1)
                }
                .onChange(of: draftName) {
                    nameError = nil
                }

            if let nameError {
                Text(nameError)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(ProfileStyle.red)
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
            save()
        } label: {
            Text("profile.save_changes".localized)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(ProfileStyle.green)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
        .padding(.top, 8)
    }

    private func save() {
        let trimmed = draftName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 2 else {
            nameError = "profile.name_error".localized
            return
        }

        name = trimmed
        onSave()
    }
}

#Preview {
    EditProfileScreen(name: .constant("profile.sample.name".localized), phoneNumber: "+20 10 1234 5678")
        .environment(LanguageManager.shared)
}
