//
//  CategoryArtworkView.swift
//  Medsy
//
//  Created by Ahmed Elkady on 12/08/2026.
//

import SwiftUI

struct CategoryArtworkView: View {
    let category: Category
    @ObservedObject private var appSettings = AppSettings.shared

    var body: some View {
        artwork
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(category.artworkName == nil ? category.bgColor : artworkBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .accessibilityHidden(true)
    }

    private var artworkBackground: Color {
        appSettings.isDarkMode ? Color(hex: "#0E1418") : Color(hex: "#FFFFFF")
    }

    private var artwork: some View {
        Group {
            if let artworkName = category.artworkName {
                Image(artworkName)
                    .resizable()
                    .scaledToFit()
            } else {
                MedsyBrandImageFallback(logoScale: 0.55)
            }
        }
    }
}
