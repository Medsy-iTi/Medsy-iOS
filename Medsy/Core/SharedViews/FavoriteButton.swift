//
//  FavoriteButton.swift
//  Medsy
//
//  Created by Shahudaa on 15/07/2026.
//


import SwiftUI

struct FavoriteButton: View {
    @Binding var isFavorite: Bool
    var size: CGFloat = 44

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isFavorite.toggle()
            }
        } label: {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .foregroundStyle(isFavorite ? AppColor.tagSold : AppColor.textPrim)
                .imageScale(.large)
                .frame(width: size, height: size)
                .background(AppColor.card)
                .clipShape(Circle())
                .medsyCardShadow()
        }
        .accessibilityLabel(isFavorite ? "accessibility.remove_favorite".localized : "accessibility.add_favorite".localized)
    }
}
