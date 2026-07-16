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
    var height: CGFloat = 260

    var body: some View {
        ZStack(alignment: .topTrailing) {
            TabView(selection: $selectedIndex) {
                ForEach(images.indices, id: \.self) { index in
                    Image(images[index])
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(MedsySpacing.lg)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: height)

            if showFavorite {
                FavoriteButton(isFavorite: $isFavorite, size: 40)
                    .padding(MedsySpacing.sm)
            }
        }
        .overlay(alignment: .bottom) {
            if images.count > 1 {
                PageDots(count: images.count, selectedIndex: selectedIndex)
                    .padding(.bottom, MedsySpacing.xs)
            }
        }
    }
}

