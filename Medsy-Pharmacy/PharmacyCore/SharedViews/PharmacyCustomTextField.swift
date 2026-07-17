//  PharmacyCustomTextField.swift
//  Medsy
//
//  Created by Antoneos Philip on 17/07/2026.

import SwiftUI

struct PharmacyCustomTextField: View {
    let title: String
    let type: PharmacyTextFieldType
    @Binding var text: String

    @State private var isPasswordVisible = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: type.systemImage)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(PharmacyColor.textSecondary)
                .frame(width: 20)

            field

            if type.isSecure {
                Button {
                    isPasswordVisible.toggle()
                } label: {
                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                        .foregroundStyle(PharmacyColor.textSecondary)
                }
                .accessibilityLabel(
                    isPasswordVisible
                        ? "auth.password.hide".localized
                        : "auth.password.show".localized
                )
            }
        }
        .font(.subheadline)
        .padding(.horizontal, 16)
        .frame(height: 56)
        .background(PharmacyColor.card, in: RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous)
                .stroke(PharmacyColor.border, lineWidth: 1)
        }
    }

    @ViewBuilder
    private var field: some View {
        if type.isSecure && !isPasswordVisible {
            SecureField(
                "",
                text: $text,
                prompt: Text(title).foregroundStyle(PharmacyColor.textSecondary)
            )
                .textContentType(type.contentType)
                .foregroundStyle(PharmacyColor.textPrimary)
        } else {
            TextField(
                "",
                text: $text,
                prompt: Text(title).foregroundStyle(PharmacyColor.textSecondary)
            )
                .textContentType(type.contentType)
                .keyboardType(type.keyboardType)
                .textInputAutocapitalization(type.usesWordCapitalization ? .words : .never)
                .autocorrectionDisabled(type == .email)
                .foregroundStyle(PharmacyColor.textPrimary)
        }
    }
}
