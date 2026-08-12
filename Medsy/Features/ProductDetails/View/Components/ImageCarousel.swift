//
//  ImageCarousel.swift
//  Medsy
//
//  Created by Shahudaa on 15/07/2026.
//

import SwiftUI

struct ImageCarousel: View {
    let images: [String]
    @Binding var selectedIndex: Int
    let isFavorite: Bool
    let onToggleFavorite: () -> Void
    var showFavorite: Bool = true
    var height: CGFloat = 240

    @Environment(\.layoutDirection) private var layoutDirection
    @ObservedObject private var appSettings = AppSettings.shared

    private var isRTL: Bool { layoutDirection == .rightToLeft }

    var body: some View {
        ZStack(alignment: isRTL ? .topLeading : .topTrailing) {
            Group {
                if images.isEmpty {
                    MedsyBrandImageFallback(logoScale: 0.5)
                } else {
                    TabView(selection: $selectedIndex) {
                        ForEach(images.indices, id: \.self) { index in
                            MedsyRemoteImage(urlString: images[index], contentMode: .fit) {
                                MedsyBrandImageFallback(logoScale: 0.5)
                            } failure: {
                                MedsyBrandImageFallback(logoScale: 0.5)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .clipped()
                            .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .flipsForRightToLeftLayoutDirection(true)
                }
            }
			.frame(width: 340 ,height: height)
			.background(AppColor.surface)
			.clipShape(RoundedRectangle(cornerRadius: MedsyRadius.lg))

            if showFavorite {
                FavoriteButton(
                    isFavorite: isFavorite,
                    size: 40,
                    action: onToggleFavorite
                )
                    .padding(MedsySpacing.sm)
            }
        }
        .overlay(alignment: .bottom) {
            if images.count > 1 {
                PageDots(
                    count: images.count,
                    selectedIndex: selectedIndex
                )
                .padding(.bottom, MedsySpacing.xs)
            }
        }
    }
}
