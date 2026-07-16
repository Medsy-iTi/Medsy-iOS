//
//  PageDots.swift
//  Medsy
//
//  Created by Shahudaa on 15/07/2026.
//

import SwiftUI

struct PageDots: View {
    let count: Int
    let selectedIndex: Int

    @Environment(\.layoutDirection) private var layoutDirection
    @ObservedObject private var appSettings = AppSettings.shared

    
    private var indices: [Int] {
        layoutDirection == .rightToLeft
            ? Array((0..<count).reversed())
            : Array(0..<count)
    }

    var body: some View {
        HStack(spacing: MedsySpacing.xxs) {
            ForEach(indices, id: \.self) { index in
                Circle()
                    .fill(index == selectedIndex ? AppColor.green : AppColor.border)
                    .frame(
                        width: index == selectedIndex ? 8 : 6,
                        height: index == selectedIndex ? 8 : 6
                    )
                    .animation(.easeInOut(duration: 0.2), value: selectedIndex)
            }
        }
        .padding(.horizontal, MedsySpacing.sm)
        .padding(.vertical, MedsySpacing.xxs)
        .background(AppColor.card.opacity(0.7))
        .clipShape(Capsule())
    }
}
