//
//  MedsyNavBarBackButton.swift
//  Medsy
//
//  Created by Ehab Salah on 23/07/2026.
//

import SwiftUI

struct MedsyNavBarBackButton: View {
    let isRTL: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: isRTL ? "chevron.right" : "chevron.left")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppColor.textPrim)
                .frame(width: 40, height: 40)
                .background(.ultraThinMaterial, in: Circle())
                .overlay {
                    Circle()
                        .stroke(.white.opacity(0.35), lineWidth: 1)
                }
                .shadow(color: .black.opacity(0.12), radius: 8, y: 3)
        }
        .buttonStyle(.plain)
        .frame(width: 44, height: 44)
    }
}
