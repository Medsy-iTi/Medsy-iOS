//
//  MedsyChatView.swift
//  Medsy
//

import SwiftUI

struct MedsyChatView: View {
    @Bindable var viewModel: ChatViewModel

    @Environment(LanguageManager.self) var lang
    @Environment(CartViewModel.self) var cartViewModel
    @ObservedObject var appSettings = AppSettings.shared

    @State var scrollProxy: ScrollViewProxy?
    let theme = MedsyTheme.default

    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            Divider().background(AppColor.border)

            ZStack(alignment: .bottom) {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: MedsySpacing.sm) {
                            disclaimerBanner
                                .padding(.top, MedsySpacing.sm)

                            if viewModel.messages.isEmpty && !viewModel.isLoading {
                                emptyState
                            }

                            ForEach(viewModel.messages) { message in
                                messageRow(message)
                            }

                            if viewModel.isLoading {
                                typingIndicator
                            }

                            Color.clear.frame(height: 1).id("bottom")
                        }
                        .padding(.horizontal, MedsySpacing.md)
                        .padding(.bottom, MedsySpacing.lg)
                    }
                    .background(AppColor.bg)
                    .onAppear {
                        scrollProxy = proxy
                    }
                    .onChange(of: viewModel.messages.count) {
                        withAnimation(.easeOut(duration: 0.25)) {
                            proxy.scrollTo("bottom")
                        }
                    }
                    .onChange(of: viewModel.isLoading) {
                        if viewModel.isLoading {
                            withAnimation(.easeOut(duration: 0.25)) {
                                proxy.scrollTo("bottom")
                            }
                        }
                    }
                }

                if let errorMessage = viewModel.errorMessage {
                    errorBanner(message: errorMessage)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: viewModel.errorMessage)
                        .padding(.bottom, MedsySpacing.sm)
                        .padding(.horizontal, MedsySpacing.md)
                }
            }

            inputBar
        }
        .background(AppColor.bg)
        .localizedEnvironment()
        .environment(lang)
        .onAppear {
            viewModel.loadHistory()
        }
    }
}

// MARK: - AppColor helpers

extension AppColor {
    static var primaryLight: Color { Color(hex: "E7F5EE") }
}
