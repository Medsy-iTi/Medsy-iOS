//
//  OTPInputView.swift
//  Medsy
//
//  Created by Ehab Salah on 17/07/2026.
//

import SwiftUI

struct OTPInputView: View {
    @Binding var code: String
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack {
            HStack(spacing: 8) {
                ForEach(0..<6, id: \.self) { index in
                    Text(digit(at: index))
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(AppColor.textPrim)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(AppColor.card, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(
                                    isFocused && index == min(code.count, 5) ? AppColor.green : AppColor.border,
                                    lineWidth: isFocused && index == min(code.count, 5) ? 2 : 1
                                )
                        }
                }
            }

            TextField("", text: $code)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($isFocused)
                .opacity(0.02)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
        }
        .contentShape(Rectangle())
        .accessibilityLabel("auth.verification.code_accessibility".localized)
        .onTapGesture {
            isFocused = true
        }
        .task {
            isFocused = true
        }
    }

    private func digit(at index: Int) -> String {
        guard index < code.count else { return "" }
        let offset = code.index(code.startIndex, offsetBy: index)
        return String(code[offset])
    }
}

#Preview {
    OTPInputView(code: .constant("123"))
        .padding()
}
