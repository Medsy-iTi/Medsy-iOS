//
//  ProfileLoadingView.swift
//  Medsy
//
//  Created by Shahudaa on 18/07/2026.
//

import SwiftUI


struct ProfileLoadingView: View {
    var body: some View {
        VStack(spacing: PharmacySpacing.md) {
            skeletonBlock(height: 70)
            skeletonBlock(height: 80)
            skeletonBlock(height: 80)
            skeletonBlock(height: 70)
        }
        .padding(PharmacySpacing.md)
        .redacted(reason: .placeholder)
        .accessibilityLabel("loading".localized)
    }

    private func skeletonBlock(height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous)
			.fill(PharmacyColor.card)
            .frame(height: height)
            .pharmacyCard(padding: nil, elevation: .subtle)
            .shimmering()
    }
}

private struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [.clear, PharmacyColor.textPrimary.opacity(0.06), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .rotationEffect(.degrees(20))
                .offset(x: phase * 400)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

private extension View {
    func shimmering() -> some View {
        modifier(ShimmerModifier())
    }
}
