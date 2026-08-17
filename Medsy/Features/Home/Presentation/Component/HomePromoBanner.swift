//
//  HomePromoBanner.swift
//  Medsy
//
//  Created by Antoneos Philip on 25/07/2026.
//

import SwiftUI

private struct HomeBanner: Identifiable {
    let id: Int
    let imageName: String
    let titleKey: String
    let subtitleKey: String
    let extraTitleKey: String
    let accessibilityKey: String
}

struct HomePromoBanner: View {
    @State private var currentIndex = 0

    private let banners = [
        HomeBanner(
            id: 0,
            imageName: "HomeBannerOne",
            titleKey: "home.promoTitle",
            subtitleKey: "home.promoDiscount",
            extraTitleKey: "home.promoTarget",
            accessibilityKey: "home.banner.image.desc.one"
        ),
        HomeBanner(
            id: 1,
            imageName: "HomeBannerTwo",
            titleKey: "home.promo2.title",
            subtitleKey: "home.promo2.discount",
            extraTitleKey: "home.promo2.target",
            accessibilityKey: "home.banner.image.desc.two"
        ),
        HomeBanner(
            id: 2,
            imageName: "HomeBannerThree",
            titleKey: "home.promo3.title",
            subtitleKey: "home.promo3.discount",
            extraTitleKey: "home.promo3.target",
            accessibilityKey: "home.banner.image.desc.three"
        )
    ]

    var body: some View {
        VStack(spacing: MedsySpacing.sm) {
            banner(banners[currentIndex])

            HStack(spacing: 6) {
                ForEach(banners.indices, id: \.self) { index in
                    Capsule()
                        .fill(index == currentIndex ? AppColor.green : AppColor.border)
                        .frame(width: index == currentIndex ? 18 : 8, height: 8)
                }
            }
            .animation(.easeInOut(duration: 0.25), value: currentIndex)
        }
        .padding(.horizontal, MedsySpacing.md)
        .frame(maxWidth: .infinity)
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(4))
                guard !Task.isCancelled else { return }
                withAnimation(.easeInOut(duration: 0.35)) {
                    currentIndex = (currentIndex + 1) % banners.count
                }
            }
        }
    }

    private func banner(_ item: HomeBanner) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Image(item.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()

                LinearGradient(
                    colors: [.black.opacity(0.65), .black.opacity(0.15)],
                    startPoint: .leading,
                    endPoint: .trailing
                )

                VStack(alignment: .leading, spacing: 6) {
                    Text(item.extraTitleKey.localized)
                        .font(AppColor.sans(12, .semibold))
                        .foregroundStyle(.white.opacity(0.8))
                    Text(item.titleKey.localized)
                        .font(AppColor.sans(22, .bold))
                        .foregroundStyle(.white)
                    Text(item.subtitleKey.localized)
                        .font(AppColor.sans(14))
                        .foregroundStyle(.white.opacity(0.9))
                }
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
            }
        }
        .frame(height: 210)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: AppColor.green.opacity(0.18), radius: 8, y: 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(item.accessibilityKey.localized)
    }
}
