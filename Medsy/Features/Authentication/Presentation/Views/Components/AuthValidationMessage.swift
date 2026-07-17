//
//  AuthValidationMessage.swift
//  Medsy
//
//  Created by Ehab Salah on 17/07/2026.
//

import SwiftUI

struct AuthValidationMessage: View {
    let message: String?

    var body: some View {
        if let message {
            Text(message)
                .font(.footnote)
                .foregroundStyle(AppColor.errorRed)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    AuthValidationMessage(message: "auth.validation.required".localized)
        .padding()
}
