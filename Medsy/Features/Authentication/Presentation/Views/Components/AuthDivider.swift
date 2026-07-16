//
//  AuthDivider.swift
//  Medsy
//
//  Created by Ehab Salah on 16/07/2026.
//

import SwiftUI

struct AuthDivider: View {
    var body: some View {
        HStack(spacing: 12) {
            Rectangle().fill(AppColor.border).frame(height: 1)
            Text("auth.or".localized)
                .font(.footnote.weight(.medium))
                .foregroundStyle(AppColor.textSec)
            Rectangle().fill(AppColor.border).frame(height: 1)
        }
    }
}
