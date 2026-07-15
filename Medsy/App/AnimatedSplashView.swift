//
//  AnimatedSplashView.swift
//  Medsy
//
//  Created by Ehab Salah on 15/07/2026.
//

import SwiftUI

struct AnimatedSplashView: View {
    let onFinished: () -> Void

    @State private var isLogoVisible = false
    @State private var hasFinished = false

    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()

            Image("SplashLogo")
                .resizable()
                .scaledToFit()
                .frame(width: min(UIScreen.main.bounds.width * 0.58, 280))
                .scaleEffect(isLogoVisible ? 1 : 0.78)
                .opacity(isLogoVisible ? 1 : 0)
                .shadow(color: AppColor.green.opacity(0.16), radius: 24, y: 10)
                .accessibilityLabel("Medsy")
        }
        .onAppear {
            guard !isLogoVisible else { return }

            withAnimation(.spring(response: 0.7, dampingFraction: 0.78)) {
                isLogoVisible = true
            }

            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(1_250))
                guard !hasFinished else { return }
                hasFinished = true
                withAnimation(.easeOut(duration: 0.22)) {
                    onFinished()
                }
            }
        }
    }
}

#Preview {
    AnimatedSplashView {}
}
