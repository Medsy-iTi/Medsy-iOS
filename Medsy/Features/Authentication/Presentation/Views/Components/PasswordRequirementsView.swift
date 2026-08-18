//
//  PasswordRequirementsView.swift
//  Medsy
//
//  Created by Ehab Salah on 18/08/2026.
//

import SwiftUI

struct PasswordRequirementsView: View {
    var body: some View {
        Label("auth.password_reset.requirements".localized, systemImage: "info.circle")
            .font(.footnote)
            .foregroundStyle(AppColor.textSec)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
    }
}
