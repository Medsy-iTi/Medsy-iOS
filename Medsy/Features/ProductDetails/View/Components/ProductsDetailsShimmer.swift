//
// ProductsDetailsShimmer.swift
//  Medsy
//
//  Created by Shahudaa on 15/07/2026.
//

import SwiftUI

// MARK: - Shimmer modifier

struct ProductsDetailsShimmer: ViewModifier {
    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        colors: [.clear, Color.white.opacity(0.35), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geo.size.width * 1.5)
                    .offset(x: phase * geo.size.width * 2)
                    .blendMode(.overlay)
                }
                .clipped()
            )
            .onAppear {
                withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    func medsyShimmer() -> some View {
        modifier(ProductsDetailsShimmer())
    }
}

// MARK: - Skeleton block

struct MedsySkeletonBlock: View {
    var cornerRadius: CGFloat = MedsyRadius.sm
    var height: CGFloat = 16
    var width: CGFloat? = nil
    @ObservedObject private var appSettings = AppSettings.shared

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(AppColor.skeleton)
            .frame(width: width, height: height)
            .medsyShimmer()
    }
}

// MARK: - Full-page skeleton

struct MedsyProductDetailSkeleton: View {
    @Environment(LanguageManager.self) private var languageManager
    @ObservedObject private var appSettings = AppSettings.shared

    var body: some View {
        VStack(spacing: MedsySpacing.md) {

            // Image placeholder
            MedsySkeletonBlock(cornerRadius: MedsyRadius.lg, height: 240)

            // Title / subtitle / price — mirror RTL alignment
            VStack(
                alignment: .leading,
                spacing: MedsySpacing.xs
            ) {
                MedsySkeletonBlock(height: 20, width: 180)
                MedsySkeletonBlock(height: 14, width: 130)
                MedsySkeletonBlock(height: 22, width: 80)
            }
            .frame(maxWidth: .infinity, alignment: .leading)


            MedsySkeletonBlock(cornerRadius: MedsyRadius.md, height: 56)

            
            VStack(spacing: MedsySpacing.xs) {
                ForEach(0..<4, id: \.self) { _ in
                    MedsySkeletonBlock(height: 40)
                }
            }


            HStack(spacing: MedsySpacing.sm) {
                MedsySkeletonBlock(cornerRadius: MedsyRadius.md, height: 52)
                MedsySkeletonBlock(cornerRadius: MedsyRadius.md, height: 52)
            }
        }
        .padding(MedsySpacing.md)
    }
}
