//
//  PharmacyAuthenticatedAsyncImage.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 24/07/2026.
//

import SwiftUI

struct PharmacyAuthenticatedAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL
    @ViewBuilder let content: (Image) -> Content
    @ViewBuilder let placeholder: () -> Placeholder

    @State private var uiImage: UIImage? = nil
    @State private var isLoading = false

    var body: some View {
        Group {
            if let uiImage = uiImage {
                content(Image(uiImage: uiImage))
            } else {
                placeholder()
                    .onAppear {
                        loadImage()
                    }
            }
        }
    }

    private func loadImage() {
        guard !isLoading else { return }
        isLoading = true

        var request = URLRequest(url: url)
        let tokenStore = KeychainTokenStore(service: PharmacyConfiguration.keychainService)
        if let token = tokenStore.accessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            defer {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.uiImage = image
                }
            }
        }
        .resume()
    }
}
