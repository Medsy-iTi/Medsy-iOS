//
//  CartView.swift
//  Medsy
//
//  Created by Ahmed Elkady on 18/07/2026.
//

import PhotosUI
import SwiftUI
import UIKit

struct CartView: View {
    @Environment(LanguageManager.self) private var languageManager
    @ObservedObject private var appSettings = AppSettings.shared
    @State private var viewModel: CartViewModel
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showsPrescriptionSources = false
    @State private var showsPhotoPicker = false
    @State private var showsCamera = false
    @State private var showsCameraUnavailable = false

    let onSearch: () -> Void
    let onContinue: (CartRequestDraft) -> Void
    let onItemCountChange: (Int) -> Void

    init(
        state: CartViewState = .loaded(CartSampleData.items),
        onSearch: @escaping () -> Void = {},
        onContinue: @escaping (CartRequestDraft) -> Void = { _ in },
        onItemCountChange: @escaping (Int) -> Void = { _ in }
    ) {
        _viewModel = State(initialValue: CartViewModel(state: state))
        self.onSearch = onSearch
        self.onContinue = onContinue
        self.onItemCountChange = onItemCountChange
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                MedsyNavBar(title: "cart.title".localized)

                content
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColor.bg.ignoresSafeArea())

            if let removedItem = viewModel.removedItem {
                CartUndoBanner(
                    message: "cart.removed_message".localized(removedItem.name),
                    onUndo: undoRemoval
                )
                .padding(.horizontal, MedsySpacing.md)
                .padding(.bottom, MedsySpacing.md)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .localizedEnvironment()
        .id(languageManager.currentLanguage)
        .preferredColorScheme(appSettings.isDarkMode ? .dark : .light)
        .onAppear { onItemCountChange(viewModel.itemCount) }
        .confirmationDialog(
            "cart.prescription.source_title".localized,
            isPresented: $showsPrescriptionSources,
            titleVisibility: .visible
        ) {
            Button("prescription.camera.title".localized) {
                openCamera()
            }

            Button("prescription.gallery.title".localized) {
                showsPhotoPicker = true
            }

            Button("common.cancel".localized, role: .cancel) {}
        }
        .photosPicker(
            isPresented: $showsPhotoPicker,
            selection: $selectedPhotoItem,
            matching: .images
        )
        .onChange(of: selectedPhotoItem) { _, item in
            loadPhoto(item)
        }
        .sheet(isPresented: $showsCamera) {
            PrescriptionCameraPicker { data in
                setPrescription(data, source: .camera)
            }
            .ignoresSafeArea()
        }
        .alert("prescription.camera.unavailable.title".localized, isPresented: $showsCameraUnavailable) {
            Button("common.ok".localized, role: .cancel) {}
        } message: {
            Text("prescription.camera.unavailable.message".localized)
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.removedItem)
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            LoadingView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .empty:
            if viewModel.prescription == nil {
                CartEmptyStateView(
                    onSearch: onSearch,
                    onUploadPrescription: presentPrescriptionSources
                )
            } else {
                cartContent(items: [])
            }

        case let .error(message):
            MedsyStatusView(
                config: MedsyStatusConfig(
                    systemIcon: "exclamationmark.triangle",
                    iconColor: { AppColor.danger },
                    iconBackground: { AppColor.danger.opacity(0.12) },
                    title: "cart.error.title".localized,
                    subtitle: message,
                    primaryButtonTitle: "error.retry".localized,
                    primaryAction: retry
                )
            )

        case let .loaded(items):
            if items.isEmpty {
                CartEmptyStateView(
                    onSearch: onSearch,
                    onUploadPrescription: presentPrescriptionSources
                )
            } else {
                cartContent(items: items)
            }
        }
    }

    private func cartContent(items: [CartDisplayItem]) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MedsySpacing.lg) {
                VStack(alignment: .leading, spacing: MedsySpacing.xs) {
                    Text("cart.subtitle".localized)
                        .font(MedsyFont.title(24))
                        .foregroundStyle(AppColor.textPrim)

                    Text("cart.message".localized)
                        .font(MedsyFont.body(15))
                        .foregroundStyle(AppColor.textSec)
                }

                if let prescription = viewModel.prescription {
                    CartPrescriptionAttachmentView(
                        attachment: prescription,
                        onChange: presentPrescriptionSources,
                        onRemove: removePrescription
                    )
                } else {
                    PrimaryButton(
                        title: "cart.prescription.add".localized,
                        systemImage: "camera",
                        style: .secondary,
                        action: presentPrescriptionSources
                    )
                }

                VStack(spacing: MedsySpacing.sm) {
                    ForEach(items) { item in
                        CartItemRow(
                            item: item,
                            onDecrease: { handleItemEvent(.decreaseQuantity(itemID: item.id)) },
                            onIncrease: { handleItemEvent(.increaseQuantity(itemID: item.id)) },
                            onRemove: { handleItemEvent(.removeItem(itemID: item.id)) }
                        )
                    }
                }

                CartTotalSummaryView(
                    estimatedTotal: viewModel.estimatedTotal,
                    canContinue: viewModel.hasContent,
                    onContinue: continueRequest
                )
                .padding(.top, MedsySpacing.xs)
            }
            .padding(.horizontal, MedsySpacing.md)
            .padding(.top, MedsySpacing.md)
            .padding(.bottom, 112)
        }
    }

    private func presentPrescriptionSources() {
        showsPrescriptionSources = true
    }

    private func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            showsCamera = true
        } else {
            showsCameraUnavailable = true
        }
    }

    private func loadPhoto(_ item: PhotosPickerItem?) {
        guard let item else { return }

        Task {
            guard let data = try? await item.loadTransferable(type: Data.self) else { return }
            setPrescription(data, source: .photoLibrary)
            selectedPhotoItem = nil
        }
    }

    private func setPrescription(_ data: Data, source: CartPrescriptionSource) {
        viewModel.handle(.setPrescription(data, source))
    }

    private func removePrescription() {
        viewModel.handle(.removePrescription)
    }

    private func handleItemEvent(_ event: CartEvent) {
        viewModel.handle(event)
        onItemCountChange(viewModel.itemCount)
    }

    private func undoRemoval() {
        viewModel.handle(.undoRemoval)
        onItemCountChange(viewModel.itemCount)
    }

    private func retry() {
        viewModel.handle(.syncSucceeded(CartSampleData.items))
        onItemCountChange(viewModel.itemCount)
    }

    private func continueRequest() {
        guard case let .continueRequest(draft) = viewModel.handle(.continueRequest) else { return }
        onContinue(draft)
    }

}
