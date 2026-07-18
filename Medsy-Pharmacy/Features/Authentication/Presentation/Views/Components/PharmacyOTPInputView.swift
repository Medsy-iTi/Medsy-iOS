//
//  PharmacyOTPInputView.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

import SwiftUI

struct PharmacyOTPInputView: View {
    @Binding var code: String
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack {
            HStack(spacing: PharmacySpacing.xs) {
                ForEach(0..<6, id: \.self) { index in
                    Text(digit(at: index))
                        .font(PharmacyColor.sans(22, .semibold))
                        .foregroundStyle(PharmacyColor.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            PharmacyColor.card,
                            in: RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous)
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous)
                                .stroke(
                                    isFocused && index == min(code.count, 5)
                                        ? PharmacyColor.primary
                                        : PharmacyColor.border,
                                    lineWidth: isFocused && index == min(code.count, 5) ? 2 : 1
                                )
                        }
                }
            }

            TextField("", text: sanitizedCode)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($isFocused)
                .opacity(0.02)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
        }
        .contentShape(Rectangle())
        .accessibilityLabel("pharmacy.auth.verification.code_accessibility".localized)
        .onTapGesture {
            isFocused = true
        }
        .task {
            isFocused = true
        }
    }

    private var sanitizedCode: Binding<String> {
        Binding(
            get: { code },
            set: { value in
                code = String(value.filter { $0.isNumber }.prefix(6))
            }
        )
    }

    private func digit(at index: Int) -> String {
        guard index < code.count else { return "" }
        let offset = code.index(code.startIndex, offsetBy: index)
        return String(code[offset])
    }
}

#Preview {
    PharmacyOTPInputView(code: .constant("123"))
        .padding()
        .background(PharmacyColor.bg)
        .environment(LanguageManager.shared)
}
