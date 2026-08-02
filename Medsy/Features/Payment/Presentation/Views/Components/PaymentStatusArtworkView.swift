//
//  PaymentStatusArtworkView.swift
//  Medsy
//
//  Created by Ahmed Elkady on 02/08/2026.
//

import SwiftUI

struct PaymentStatusArtworkView: View {
    let status: PaymentStatusPresentation

    var body: some View {
        ZStack {
            Circle()
                .fill(status.tint.opacity(0.12))
                .frame(width: 120, height: 120)

            Circle()
                .fill(status.tint)
                .frame(width: 84, height: 84)

            if status.showsProgress {
                ProgressView()
                    .controlSize(.large)
                    .tint(.white)
            } else {
                Image(systemName: status.systemImage)
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .accessibilityHidden(true)
    }
}

#Preview {
    HStack {
        PaymentStatusArtworkView(status: .processing)
        PaymentStatusArtworkView(status: .success)
        PaymentStatusArtworkView(status: .failure(message: nil))
    }
    .padding()
}
