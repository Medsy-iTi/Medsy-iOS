//
//  AppRootView.swift
//  Medsy
//
//  Created by Ehab Salah on 15/07/2026.
//

import SwiftUI

struct AppRootView: View {
    private let onboardingFactory: OnboardingFactory
    @State private var isShowingOnboarding: Bool

    init(onboardingFactory: OnboardingFactory) {
        self.onboardingFactory = onboardingFactory
        _isShowingOnboarding = State(initialValue: onboardingFactory.shouldShow())
    }

    var body: some View {
        Group {
            if isShowingOnboarding {
                onboardingFactory.makeView {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isShowingOnboarding = false
                    }
                }
                .transition(.opacity)
            } else {
                ContentView()
                    .transition(.opacity)
            }
        }
    }
}


