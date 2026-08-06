//
//  PharmacyChatView.swift
//  Medsy-Pharmacy

import SwiftUI

struct PharmacyChatView: View {
    @State var viewModel: PharmacyAiChatViewModel
    @FocusState var isInputFocused: Bool
    @State private var showingImagePicker = false
    @Namespace var bottomID

    var body: some View {
        VStack(spacing: 0) {
            navigationBar
                .padding(.horizontal, PharmacySpacing.md)
                .padding(.vertical, 10)
                .background(PharmacyColor.surface)
                .shadow(color: .black.opacity(0.03), radius: 4, y: 2)
                .zIndex(1)

            if viewModel.isLoadingHistory {
                loadingState
            } else if viewModel.historyLoadFailed {
                errorState
            } else if viewModel.messages.isEmpty {
                emptyState
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 24) {
                            ForEach(viewModel.messages) { message in
                                messageRow(for: message)
                            }
                            Color.clear
                                .frame(height: 10)
                                .id(bottomID)
                        }
                        .padding(.horizontal, PharmacySpacing.md)
                        .padding(.vertical, PharmacySpacing.lg)
                    }
                    .onChange(of: viewModel.messages.count) { _, _ in
                        withAnimation {
                            proxy.scrollTo(bottomID, anchor: .bottom)
                        }
                    }
                    .onAppear {
                        proxy.scrollTo(bottomID, anchor: .bottom)
                    }
                }
            }

            // Input Bar
            VStack(spacing: 0) {
                Divider().background(PharmacyColor.border)
                
                if let err = viewModel.errorMessage {
                    HStack {
                        Image(systemName: "exclamationmark.circle.fill")
                        Text(err)
                            .font(PharmacyColor.sans(13))
                        Spacer()
                        Button(action: { viewModel.dismissError() }) {
                            Image(systemName: "xmark")
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(PharmacyColor.danger)
                }

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
                    .padding(.top, PharmacySpacing.sm)
                }

                HStack(spacing: 12) {
                    Button(action: { showingImagePicker = true }) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 20))
                            .foregroundColor(PharmacyColor.primary)
                            .frame(width: 44, height: 44)
                            .background(PharmacyColor.primarySoft)
                            .clipShape(Circle())
                    }
                    .disabled(viewModel.isSending || !viewModel.session.isHistoryLoaded)

                    TextField("pharmacy.chatbot.input.placeholder".localized, text: $viewModel.inputText, axis: .vertical)
                        .font(PharmacyColor.sans(15))
                        .focused($isInputFocused)
                        .lineLimit(1...5)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(PharmacyColor.mutedSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(PharmacyColor.border, lineWidth: 1)
                        )
                        .disabled(viewModel.isSending || !viewModel.session.isHistoryLoaded)

                    Button(action: {
                        if viewModel.selectedImage != nil {
                            viewModel.sendWithImage()
                        } else {
                            viewModel.sendText()
                        }
                    }) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(viewModel.isSendEnabled ? PharmacyColor.primary : PharmacyColor.border)
                            .clipShape(Circle())
                    }
                    .disabled(!viewModel.isSendEnabled)
                }
                .padding(.horizontal, PharmacySpacing.md)
                .padding(.vertical, PharmacySpacing.sm)
                .padding(.bottom, 8)
                .background(PharmacyColor.surface)
            }
        }
        .background(PharmacyColor.bg.ignoresSafeArea())
        .onAppear {
            viewModel.onAppear()
        }
        // NOTE: We omit sheet(isPresented: $showingImagePicker) here to keep it simple,
        // it requires ImagePicker view which exists in Medsy/SharedCore depending on where it was placed.
    }
}
