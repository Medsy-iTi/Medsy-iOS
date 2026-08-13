//
//  MedsyChatView.swift
//  Medsy
//
//  Created by Ahmed Elkady on 12/08/2026.
//

import SwiftUI
import PhotosUI

struct MedsyChatView: View {
    @Bindable var viewModel: AiChatViewModel
    @Environment(LanguageManager.self) var lang
    @Environment(CartViewModel.self) var cartViewModel
    @ObservedObject var appSettings = AppSettings.shared
    @State var scrollProxy: ScrollViewProxy?
    @State var showImagePicker = false
    @State var photosPickerItem: PhotosPickerItem?
    var onBack: (() -> Void)? = nil

    var theme: MedsyTheme { .default }

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
                            if viewModel.isLoadingHistory {
                                historyLoadingIndicator
                            } else if viewModel.historyLoadFailed {
                                historyFailedBanner
                            }
                            if viewModel.messages.isEmpty && !viewModel.isSending && !viewModel.isLoadingHistory {
                                emptyState
                            }
                            ForEach(viewModel.messages) { message in
                                messageRow(message)
                            }
                            if viewModel.isSending {
                                typingIndicator
                            }
                            Color.clear.frame(height: 1).id("bottom")
                        }
                        .padding(.horizontal, MedsySpacing.md)
                        .padding(.bottom, MedsySpacing.lg)
                    }
                    .background(AppColor.bg)
                    .onAppear { scrollProxy = proxy }
                    .onChange(of: viewModel.messages.count) {
                        withAnimation(.easeOut(duration: 0.25)) { proxy.scrollTo("bottom") }
                    }
                    .onChange(of: viewModel.isSending) {
                        if viewModel.isSending {
                            withAnimation(.easeOut(duration: 0.25)) { proxy.scrollTo("bottom") }
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
            // Image preview above input bar
            if let img = viewModel.selectedImage {
                AiChatImagePreview(image: img, onDismiss: { viewModel.selectedImage = nil })
                    .padding(.horizontal, MedsySpacing.md)
                    .padding(.top, MedsySpacing.xs)
            }
            inputBar
        }
        .background(AppColor.bg)
        .localizedEnvironment()
        .environment(lang)
        .onAppear { viewModel.onAppear() }
        .photosPicker(isPresented: $showImagePicker, selection: $photosPickerItem, matching: .images)
        .onChange(of: photosPickerItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    viewModel.selectedImage = uiImage
                }
                photosPickerItem = nil
            }
        }
    }
}

extension AppColor {
    static var primaryLight: Color { primaryContainer }
}
