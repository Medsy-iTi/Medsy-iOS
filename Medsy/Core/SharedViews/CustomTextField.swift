//
//  CustomTextField.swift
//  Medsy
//
//  Created by Ehab Salah on 15/07/2026.
//

import SwiftUI


struct CustomTextField: View {
    let title: String
    let type: TextFieldType
    @Binding var text: String

    @State private var isPasswordVisible = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: type.systemImage)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AppColor.textSec)
                .frame(width: 20)

            field

            if type.isSecure {
                Button {
                    isPasswordVisible.toggle()
                } label: {
                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                        .foregroundStyle(AppColor.textSec)
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
        .background(AppColor.card, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(AppColor.border, lineWidth: 1)
        }
    }

    @ViewBuilder
    private var field: some View {
        if type.isSecure && !isPasswordVisible {
            SecureField(title, text: $text)
                .textContentType(type.contentType)
        } else {
            TextField(title, text: $text)
                .textContentType(type.contentType)
                .keyboardType(type.keyboardType)
                .textInputAutocapitalization(type.usesWordCapitalization ? .words : .never)
                .autocorrectionDisabled(type == .email)
        }
    }
}
