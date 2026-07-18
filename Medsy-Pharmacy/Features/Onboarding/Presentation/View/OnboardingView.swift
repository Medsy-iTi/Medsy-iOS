//
//  OnboardingView.swift
//  Medsy-Pharmacy
//
//

import SwiftUI

struct OnboardingView: View {
    @State var viewModel: OnboardingViewModel
    @State private var buttonPressed = false

    var body: some View {
        ZStack {
            PharmacyColor.bg
                .ignoresSafeArea()

            WaveShape(amplitude: 26, verticalOffset: 0.9)
                .fill(PharmacyColor.primarySoft)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    if !viewModel.isLastPage {
                        Button {
                            viewModel.skip()
                        } label: {
                            Text("pharmacy.onboarding.skip".localized)
                                .font(PharmacyColor.sans(15, .semibold))
                                .foregroundStyle(PharmacyColor.primary)
                        }
                    }
                }
                .padding(.horizontal, PharmacySpacing.lg)
                .padding(.top, PharmacySpacing.sm)
                .frame(height: 36)
                .animation(.easeInOut(duration: 0.2), value: viewModel.isLastPage)

                TabView(selection: $viewModel.currentIndex) {
                    ForEach(Array(viewModel.pages.enumerated()), id: \.element.id) { index, page in
                        OnboardingPageView(page: page, isActive: viewModel.currentIndex == index)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.35), value: viewModel.currentIndex)

                PageIndicatorView(pageCount: viewModel.pages.count, currentIndex: viewModel.currentIndex)
                    .padding(.bottom, PharmacySpacing.lg)

                Button {
                    withAnimation(.easeOut(duration: 0.15)) { buttonPressed = true }
                    viewModel.advance()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation(.easeOut(duration: 0.15)) { buttonPressed = false }
                    }
                } label: {
                    Text(currentActionTitle)
                        .font(PharmacyColor.sans(16, .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, PharmacySpacing.sm + 2)
                        .background(PharmacyColor.primary, in: Capsule())
                        .scaleEffect(buttonPressed ? 0.97 : 1)
                }
                .padding(.horizontal, PharmacySpacing.lg)
                .padding(.bottom, PharmacySpacing.lg)
            }
        }
    }

    private var currentActionTitle: String {
        guard let page = viewModel.pages[safe: viewModel.currentIndex] else { return "" }
        return page.primaryActionKey.localized
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    OnboardingView(
        viewModel: OnboardingViewModel(
            getPagesUseCase: GetOnboardingPagesUseCase(repository: OnboardingRepository()),
            onComplete: {}
        )
    )
}
