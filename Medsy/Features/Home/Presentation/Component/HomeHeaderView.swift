//
//  HomeHeaderView.swift
//  Medsy
//
//  Created by Antoneos Philip on 25/07/2026.
//

import SwiftUI

struct HomeHeaderView: View {
    let homeAddress: String
    let favoriteCount: Int
    let onFavoritesTap: () -> Void
    let onAddressTap: () -> Void

    var body: some View {
        HStack(spacing: MedsySpacing.sm) {
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    onFavoritesTap()
                }
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "heart")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(AppColor.textPrim)
                        .frame(width: 44, height: 44)
                        .background(AppColor.card, in: Circle())

                    if favoriteCount > 0 {
                        Text(badgeText)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(minWidth: 18, minHeight: 18)
                            .padding(.horizontal, favoriteCount > 9 ? 3 : 0)
                            .background(Color.red, in: Capsule())
                            .overlay {
                                Capsule().stroke(AppColor.bg, lineWidth: 2)
                            }
                            .offset(x: 4, y: -4)
                            .accessibilityHidden(true)
                    }
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("favorites.open.accessibility".localized)
            .accessibilityValue("favorites.count.accessibility".localized(favoriteCount))

            Spacer()

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

    private var badgeText: String {
        favoriteCount > 99 ? "99+" : String(favoriteCount)
    }
}
