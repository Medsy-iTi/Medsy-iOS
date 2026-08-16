//
//  AuthScreenContainer.swift
//  Medsy
//
//  Created by Ehab Salah on 16/07/2026.
//

import SwiftUI
import UIKit

struct AuthScreenContainer<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                content
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 32)
            .frame(maxWidth: 560)
            .frame(maxWidth: .infinity)
        }
        .scrollDismissesKeyboard(.interactively)
        .scrollIndicators(.hidden)
        .background {
            AppColor.bg
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture(perform: dismissKeyboard)
        }
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}
