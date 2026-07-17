//
//  SignupDatePicker.swift
//  Medsy
//
//  Created by Ehab Salah on 17/07/2026.
//

import SwiftUI

struct SignupDatePicker: View {
    @Binding var dateOfBirth: Date
    var body: some View {
        DatePicker(
            "auth.date_of_birth".localized,
            selection: $dateOfBirth,
            in: ...Date(),
            displayedComponents: .date
        )
        .font(.subheadline)
        .foregroundStyle(AppColor.textPrim)
        .tint(AppColor.green)
        .padding(.horizontal, 16)
        .frame(height: 56)
        .background(AppColor.card, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(AppColor.border, lineWidth: 1)
        }
    }
}

#Preview {
//    SignupDatePicker()
}
