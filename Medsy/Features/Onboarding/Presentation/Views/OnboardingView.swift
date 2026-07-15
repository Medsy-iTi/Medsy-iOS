//
//  OnboardingView.swift
//  Medsy
//
//  Created by Ehab Salah on 15/07/2026.
//

import SwiftUI

struct OnboardingView: View {
    @State private var viewModel: OnboardingViewModel

    init(viewModel: OnboardingViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        VStack(spacing: 0) {
            OnboardingHeader(onSkip: viewModel.skip)

            TabView(selection: $viewModel.currentPageIndex) {
                ForEach(viewModel.pages) { page in
                    OnboardingPageView(page: page)
                        .tag(page.id)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            VStack(spacing: 24) {
                OnboardingPageIndicator(
                    pageCount: viewModel.pages.count,
                    currentPage: viewModel.currentPageIndex
                )

                PrimaryButton(
                    title: viewModel.primaryButtonTitle,
                    systemImage: viewModel.isLastPage ? nil : "chevron.forward",
                    action: viewModel.performPrimaryAction
                )
            }
            .padding(.top, 12)
            .padding(.bottom, 10)
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: 620)
        .frame(maxWidth: .infinity)
        .background(Color(uiColor: .systemBackground))
    }
}
