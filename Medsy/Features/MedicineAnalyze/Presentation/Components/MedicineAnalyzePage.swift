//
//  MedicineAnalyzePage.swift
//  Medsy
//
//  Created by Ehab Salah on 23/07/2026.
//

import SwiftUI

struct MedicineAnalyzePage<Content: View>: View {
    let onBack: () -> Void
    let content: Content

    init(onBack: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.onBack = onBack
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            MedsyNavBar(
                title: "medicineAnalyze.title".localized,
                onBack: onBack
            ) {
                EmptyView()
            }
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(AppColor.bg)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarHidden(true)
    }
}
