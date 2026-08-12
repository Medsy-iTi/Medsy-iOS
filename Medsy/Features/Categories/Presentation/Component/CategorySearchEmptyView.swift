//
//  CategorySearchEmptyView.swift
//  Medsy
//
//  Created by Ahmed Elkady on 12/08/2026.
//

import SwiftUI

struct CategorySearchEmptyView: View {
    var body: some View {
        MedsyLottieView(animationName: "no_data")
            .frame(width: 250, height: 250)
            .accessibilityHidden(true)
    }
}
