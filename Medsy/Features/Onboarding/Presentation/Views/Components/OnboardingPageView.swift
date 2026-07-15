//
//  OnboardingPageView.swift
//  Medsy
//
//  Created by Ehab Salah on 15/07/2026.
//

import SwiftUI

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: 24) {
                    Spacer(minLength: 4)

                    OnboardingImageView(imageName: page.imageName)
                        .frame(
                            maxWidth: min(proxy.size.width * 0.82, 420),
                            maxHeight: min(proxy.size.height * 0.58, 420)
                        )

                    VStack(spacing: 12) {
                        Text(page.titleKey.localized)
                            .font(.title2.bold())
                            .foregroundStyle(AppColor.green)
                            .multilineTextAlignment(.center)

                        Text(page.bodyKey.localized)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .frame(maxWidth: 430)
                    }

                    Spacer(minLength: 8)
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: proxy.size.height)
                .padding(.horizontal, 8)
            }
            .scrollIndicators(.hidden)
        }
    }
}

#Preview {
    OnboardingPageView(page: OnboardingPage.pages[0])
        .padding()
}
