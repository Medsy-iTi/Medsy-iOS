//
//  SkeletonRow.swift
//  Medsy
//
//  Created by Shahudaa on 15/07/2026.
//

import SwiftUI


struct SkeletonRow: View {
    @State private var isAnimating = false
    @Environment(\.layoutDirection) private var layoutDirection
    @ObservedObject private var appSettings = AppSettings.shared

    private var isRTL: Bool { layoutDirection == .rightToLeft }

    var body: some View {
        HStack(spacing: MedsySpacing.sm) {

                
                shimmerShape.frame(width: 72, height: 72).clipShape(RoundedRectangle(cornerRadius: MedsyRadius.md))
                textShimmers
                actionShimmers
           
        }
        .padding(MedsySpacing.sm)
        .frame(height: 96)
        .background(
            RoundedRectangle(cornerRadius: MedsyRadius.lg)
                .fill(AppColor.card)
                .overlay(
                    RoundedRectangle(cornerRadius: MedsyRadius.lg)
                        .stroke(AppColor.border, lineWidth: 1)
                )
        )
    }

    private var actionShimmers: some View {
        VStack(spacing: MedsySpacing.sm) {
            shimmerShape.frame(width: 20, height: 20).clipShape(Circle())
            Spacer(minLength: 0)
            shimmerShape.frame(width: 26, height: 26).clipShape(Circle())
        }
    }

    private var textShimmers: some View {
        VStack(
            alignment: isRTL ? .trailing : .leading,
            spacing: MedsySpacing.xs
        ) {
            shimmerShape.frame(width: 120, height: 14)
            shimmerShape.frame(width: 80, height: 10)
            Spacer(minLength: MedsySpacing.sm)
            shimmerShape.frame(width: 50, height: 12)
        }
        .frame(maxWidth: .infinity, alignment: isRTL ? .trailing : .leading)
    }

    private var shimmerShape: some View {
        RoundedRectangle(cornerRadius: MedsyRadius.sm)
            .fill(AppColor.skeleton)
            .opacity(isAnimating ? 0.5 : 1)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
    }
}

struct MedsySkeletonList: View {
    var rowCount: Int = 5
    var body: some View {
        VStack(spacing: MedsySpacing.sm) {
            ForEach(0..<rowCount, id: \.self) { _ in
                SkeletonRow()
            }
        }
    }
}
