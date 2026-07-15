//
//  AuthHeader.swift
//  Medsy
//

import SwiftUI

struct AuthHeader: View {
    let title: String
    let subtitle: String
    var showsBrand = false

    var body: some View {
        VStack(spacing: 10) {
            if showsBrand {
                BrandMark()
            } else {
                Text(title)
                    .font(.title2.bold())
                    .foregroundStyle(AppColor.textPrim)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(AppColor.textSec)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

private struct BrandMark: View {
    var body: some View {
        VStack(spacing: 7) {
            Image("AuthLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 108, height: 108)
                .accessibilityHidden(true)

            Text("auth.brand.name".localized)
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(AppColor.green)

            Text("auth.brand.tagline".localized)
                .font(.footnote.weight(.medium))
                .foregroundStyle(AppColor.textPrim)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\("auth.brand.name".localized), \("auth.brand.tagline".localized)"
        )
    }
}
