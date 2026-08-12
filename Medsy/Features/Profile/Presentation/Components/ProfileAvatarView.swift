//
//  ProfileAvatarView.swift
//  Medsy
//
//  Created by Ahmed Elkady on 15/07/2026.
//

import SwiftUI

struct ProfileAvatarView: View {
    let size: CGFloat
    let showsBadge: Bool

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            AppColor.green,
                            Color(hex: "#047A43")
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: AppColor.green.opacity(0.36), radius: 10, y: 6)
                .frame(width: size, height: size)
                .overlay {
                    Image(systemName: "person")
                        .font(.system(size: size * 0.44, weight: .medium))
                        .foregroundStyle(Color(hex: "#EEF7F2"))
                }

            if showsBadge {
                Circle()
                    .fill(AppColor.successGreen)
                    .frame(width: size * 0.32, height: size * 0.32)
                    .overlay {
                        Image(systemName: "checkmark")
                            .font(.system(size: size * 0.16, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .shadow(color: .black.opacity(0.18), radius: 2, y: 1)
            }
        }
        .accessibilityHidden(true)
    }
}

#Preview {
    ZStack {
        AppColor.background
        ProfileAvatarView(size: 80, showsBadge: true)
    }
}
