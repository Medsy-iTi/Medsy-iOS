//
//  PharmacyAvatarView.swift
//  Medsy
//
//  Created by Shahudaa on 18/07/2026.
//


import SwiftUI

struct PharmacyAvatarView: View {
    let url: URL?
    var systemFallback: String = "person.fill"

    var body: some View {
        ZStack {
            Circle()
                .fill(PharmacyColor.primarySoft)

            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    case .failure, .empty:
                        fallbackIcon
                    @unknown default:
                        fallbackIcon
                    }
                }
            } else {
                fallbackIcon
            }
        }
        .clipShape(Circle())
        .overlay(Circle().stroke(PharmacyColor.border, lineWidth: 1))
    }

    private var fallbackIcon: some View {
        Image(systemName: systemFallback)
            .font(.system(size: 20, weight: .medium))
            .foregroundStyle(PharmacyColor.primary)
    }
}
