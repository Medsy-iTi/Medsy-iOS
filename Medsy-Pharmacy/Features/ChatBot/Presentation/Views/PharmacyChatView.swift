//
//  PharmacyChatView.swift
//  Medsy-Pharmacy

import SwiftUI
import PhotosUI

struct PharmacyChatView: View {
    @State var viewModel: PharmacyAiChatViewModel
    @Environment(LanguageManager.self) var lang
    @ObservedObject var appSettings = PharmacyAppSettings.shared
    @State private var scrollProxy: ScrollViewProxy?
    @State private var showingImagePicker = false
    @State private var photosPickerItem: PhotosPickerItem?

    var body: some View {
        VStack(spacing: 0) {
            navigationBar
                .zIndex(1)

            Divider().background(PharmacyColor.border)

            ZStack(alignment: .bottom) {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: PharmacySpacing.sm) {
                            disclaimerBanner
                                .padding(.top, PharmacySpacing.sm)

                            if viewModel.isLoadingHistory {
                                historyLoadingIndicator
                            } else if viewModel.historyLoadFailed {
                                historyFailedBanner
                            }

                            if viewModel.messages.isEmpty && !viewModel.isSending && !viewModel.isLoadingHistory {
                                emptyState
                            }

                            ForEach(viewModel.messages) { message in
                                messageRow(for: message)
                            }

                            if viewModel.isSending {
                                typingIndicator
                            }

                            Color.clear.frame(height: 1).id("bottom")
                        }
                        .padding(.horizontal, PharmacySpacing.md)
                        .padding(.bottom, PharmacySpacing.lg)
                    }
                    .background(PharmacyColor.bg)
                    .onAppear { scrollProxy = proxy }
                    .onChange(of: viewModel.messages.count) { _, _ in
                        withAnimation(.easeOut(duration: 0.25)) { proxy.scrollTo("bottom") }
                    }
                    .onChange(of: viewModel.isSending) { _, sending in
                        if sending {
                            withAnimation(.easeOut(duration: 0.25)) { proxy.scrollTo("bottom") }
                        }
                    }
                }

                if let errorMessage = viewModel.errorMessage {
                    errorBanner(message: errorMessage)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: viewModel.errorMessage)
                        .padding(.bottom, PharmacySpacing.sm)
                        .padding(.horizontal, PharmacySpacing.md)
                }
            }

            // Image preview above input bar
            if let image = viewModel.selectedImage {
                HStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            Button(action: { viewModel.selectedImage = nil }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.white)
                                    .background(Color.black.opacity(0.5).clipShape(Circle()))
                            }
                            .padding(4),
                            alignment: .topTrailing
                        )
                    Spacer()
                }
                .padding(.horizontal, PharmacySpacing.md)
                .padding(.top, PharmacySpacing.xs)
                .background(PharmacyColor.surface)
            }

            // Input Bar
            VStack(spacing: 0) {
                Divider().background(PharmacyColor.border)
                
                PharmacyChatInputBar(
                    text: $viewModel.inputText,
                    placeholder: "pharmacy.chatbot.input.placeholder".localized,
                    isRecording: viewModel.isRecording,
                    isSendEnabled: viewModel.isSendEnabled,
                    onSend: {
                        if viewModel.selectedImage != nil {
                            viewModel.sendWithImage()
                        } else {
                            viewModel.sendText()
                        }
                    },
                    onCamera: { showingImagePicker = true },
                    onMic: { viewModel.toggleRecording() },
                    disabled: !viewModel.session.isHistoryLoaded
                )
                .padding(.horizontal, PharmacySpacing.sm)
                .padding(.vertical, PharmacySpacing.sm)
            }
            .background(PharmacyColor.surface)
        }
        .background(PharmacyColor.bg.ignoresSafeArea())
        .pharmacyLocalizedEnvironment()
        .environment(lang)
        .onAppear {
            viewModel.onAppear()
        }
        .photosPicker(isPresented: $showingImagePicker, selection: $photosPickerItem, matching: .images)
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
