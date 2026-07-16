//
//  AuthPrompt.swift
//  Medsy
//
//  Created by Ehab Salah on 16/07/2026.
//

import SwiftUI

struct AuthPrompt: View {
    let leadingText: String
    let actionTitle: String
    let action: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text(leadingText)
                .foregroundStyle(AppColor.textSec)
            Button(actionTitle, action: action)
                .fontWeight(.semibold)
                .foregroundStyle(AppColor.green)
        }
        .font(.footnote)
        .frame(maxWidth: .infinity)
    }
}
