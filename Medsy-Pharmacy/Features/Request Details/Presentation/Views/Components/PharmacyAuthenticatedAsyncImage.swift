//
//  PharmacyAuthenticatedAsyncImage.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 24/07/2026.
//

import SwiftUI

struct PharmacyAuthenticatedAsyncImage<Content: View, Placeholder: View>: View {
    let uiImage: UIImage?
    @ViewBuilder let content: (Image) -> Content
    @ViewBuilder let placeholder: () -> Placeholder

    var body: some View {
        if let uiImage = uiImage {
            content(Image(uiImage: uiImage))
        } else {
            placeholder()
        }
    }
}
