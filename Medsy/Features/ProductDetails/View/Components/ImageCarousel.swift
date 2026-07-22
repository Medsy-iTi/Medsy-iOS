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
    @Binding var isFavorite: Bool
    var showFavorite: Bool = true
    var height: CGFloat = 240

    @Environment(\.layoutDirection) private var layoutDirection
    @ObservedObject private var appSettings = AppSettings.shared

    private var isRTL: Bool { layoutDirection == .rightToLeft }

    var body: some View {
        ZStack(alignment: isRTL ? .topLeading : .topTrailing) {
            TabView(selection: $selectedIndex) {
                ForEach(images.indices, id: \.self) { index in
                    if let url = URL(string: images[index]) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .padding(MedsySpacing.lg)
                            case .empty:
                                ProgressView()
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            default:
                                Image(systemName: "photo")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .padding(MedsySpacing.lg)
                                    .foregroundColor(AppColor.textSec.opacity(0.3))
                            }
                        }
                        .tag(index)
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(MedsySpacing.lg)
                            .foregroundColor(AppColor.textSec.opacity(0.3))
                            .tag(index)
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .flipsForRightToLeftLayoutDirection(true)
			.frame(width: 340 ,height: height)
			.background(.white)
			.clipShape(RoundedRectangle(cornerRadius: MedsyRadius.lg))

            if showFavorite {
                FavoriteButton(isFavorite: $isFavorite, size: 40)
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
