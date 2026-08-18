//
//  ForgotPasswordButton.swift
//  Medsy
//
//  Created by Ehab Salah on 18/08/2026.
//

import SwiftUI

struct ForgotPasswordButton: View {
    let action: () -> Void

    var body: some View {
        Button("auth.forgot_password".localized, action: action)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(AppColor.green)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .accessibilityHint("auth.password_reset.forgot.accessibility_hint".localized)
    }
}
