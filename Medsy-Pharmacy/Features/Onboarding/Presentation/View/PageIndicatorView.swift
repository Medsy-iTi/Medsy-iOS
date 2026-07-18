//
//  PageIndicatorView.swift
//  Medsy-Pharmacy
//
//

import SwiftUI

struct PageIndicatorView: View {
    let pageCount: Int
    let currentIndex: Int

    var body: some View {
        HStack(spacing: PharmacySpacing.xs) {
            ForEach(0..<pageCount, id: \.self) { index in
                Capsule()
                    .fill(index == currentIndex ? PharmacyColor.primary : PharmacyColor.border)
                    .frame(width: index == currentIndex ? 22 : 8, height: 8)
                    .animation(.spring(response: 0.4, dampingFraction: 0.75), value: currentIndex)
            }
        }
    }
}

#Preview {
    PageIndicatorView(pageCount: 3, currentIndex: 1)
        .padding()
}
