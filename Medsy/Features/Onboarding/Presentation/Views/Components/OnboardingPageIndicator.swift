//
//  OnboardingPageIndicator.swift
//  Medsy
//
//  Created by Ehab Salah on 15/07/2026.
//

import SwiftUI

struct OnboardingPageIndicator: View {
    let pageCount: Int
    let currentPage: Int

    var body: some View {
        HStack(spacing: 9) {
            ForEach(0..<pageCount, id: \.self) { index in
                Capsule(style: .continuous)
                    .fill(index == currentPage ? AppColor.green : Color.secondary.opacity(0.22))
                    .frame(width: index == currentPage ? 24 : 8, height: 8)
            }
        }
        .animation(.easeInOut(duration: 0.24), value: currentPage)
    }
}

#Preview {
    OnboardingPageIndicator(pageCount: 3, currentPage: 1)
        .padding()
}
