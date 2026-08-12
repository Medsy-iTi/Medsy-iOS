//  HomeHeaderView.swift
//  Medsy
//
//  Created by Antoneos Philip on 14/07/2026.
//

import SwiftUI

struct HomeHeaderView: View {
    let homeAddress: String
    let onAddressTap: () -> Void

    var body: some View {
        HStack(spacing: MedsySpacing.sm) {
            Button(action: onAddressTap) {
                HStack(spacing: 7) {
                    Image(systemName: "location.fill")
                        .font(.subheadline)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("home.deliveryTo".localized)
                            .font(AppColor.sans(11, .regular))
                            .foregroundStyle(AppColor.textSec)

                        Text(homeAddress)
                            .font(AppColor.sans(14, .bold))
                            .foregroundStyle(AppColor.textPrim)
                            .lineLimit(1)
                    }

                    Image(systemName: "chevron.forward")
                        .font(.caption.weight(.semibold))
                }
                .foregroundStyle(AppColor.textPrim)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(
                "\("home.deliveryTo".localized), \(homeAddress)"
            )

            Spacer(minLength: MedsySpacing.md)

            Image("AuthLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 56, height: 56)
                .accessibilityHidden(true)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}
