//
//  CartView.swift
//  Medsy
//
//  Created by Ahmed Elkady on 18/07/2026.
//

import SwiftUI

struct CartView: View {
    @Environment(LanguageManager.self) private var languageManager
    @ObservedObject private var appSettings = AppSettings.shared
    private let viewModel: CartViewModel
    @State private var showsClearConfirmation = false
    @State private var operationErrorMessage: String?
    @State private var showsNoteEditor = false
    @State private var noteInput = ""

    let onSearch: () -> Void
    let onScanPrescription: () -> Void
    let onContinue: (CartRequestDraft) -> Void
    let onProductSelected: (String) -> Void
    let onReminders: (() -> Void)?

    init(
        viewModel: CartViewModel,
        onSearch: @escaping () -> Void = {},
        onScanPrescription: @escaping () -> Void = {},
        onContinue: @escaping (CartRequestDraft) -> Void = { _ in },
        onProductSelected: @escaping (String) -> Void = { _ in },
        onReminders: (() -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.onSearch = onSearch
        self.onScanPrescription = onScanPrescription
        self.onContinue = onContinue
        self.onProductSelected = onProductSelected
        self.onReminders = onReminders
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                MedsyNavBar(title: "cart.title".localized, trailing: {
                    HStack(spacing: MedsySpacing.md) {
                        Button {
                            onReminders?()
                        } label: {
                            Image(systemName: "bell.fill")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(AppColor.green)
                        }
                        .accessibilityLabel("reminders.title".localized)

                        Button {
                            showsClearConfirmation = true
                        } label: {
                            Image(systemName: "trash")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(AppColor.danger)
                        }
                        .accessibilityLabel("cart.clear.accessibility".localized)
                        .disabled(!viewModel.hasContent)
                        .opacity(viewModel.hasContent ? 1 : 0.35)
                    }
                })

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
        .preferredColorScheme(appSettings.preferredColorScheme)
        .alert("cart.clear_confirmation.title".localized, isPresented: $showsClearConfirmation) {
            Button("common.cancel".localized, role: .cancel) {}
            Button("cart.clear_confirmation.action".localized, role: .destructive) {
                viewModel.handle(.clear)
            }
        } message: {
            Text("cart.clear_confirmation.message".localized)
        }
        .alert(
            "cart.error.title".localized,
            isPresented: Binding(
                get: { operationErrorMessage != nil },
                set: { if !$0 { operationErrorMessage = nil } }
            )
        ) {
            Button("common.ok".localized, role: .cancel) {}
        } message: {
            Text(operationErrorMessage ?? "")
        }
        .sheet(isPresented: $showsNoteEditor) {
            NavigationStack {
                VStack(alignment: .leading, spacing: MedsySpacing.md) {
                    Text("cart.note.hint".localized)
                        .font(MedsyFont.body(15))
                        .foregroundStyle(AppColor.textSec)

                    TextEditor(text: $noteInput)
                        .font(MedsyFont.body(15))
                        .localizedTextInput()
                        .padding(MedsySpacing.sm)
                        .frame(minHeight: 140)
                        .scrollContentBackground(.hidden)
                        .background(AppColor.card)
                        .overlay {
                            RoundedRectangle(cornerRadius: MedsyRadius.md)
                                .stroke(AppColor.border, lineWidth: 1)
                        }
                        .onChange(of: noteInput) { _, value in
                            if value.count > 500 { noteInput = String(value.prefix(500)) }
                        }

                    Spacer()
                }
                .padding(MedsySpacing.md)
                .background(AppColor.bg.ignoresSafeArea())
                .navigationTitle("cart.note.title".localized)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("cart.note.cancel".localized) { showsNoteEditor = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("cart.note.save".localized) {
                            viewModel.handle(.updatePharmacistNote(noteInput))
                            showsNoteEditor = false
                        }
                    }
                }
            }
            .presentationDetents([.medium])
        }
        .onChange(of: viewModel.syncState) { _, state in
            guard case let .failed(message) = state else { return }
            operationErrorMessage = message
        }
        .task(id: languageManager.languageCode) {
            await viewModel.refreshInteractions(language: languageManager.languageCode)
        }
        .task(id: viewModel.removedItem?.id) {
            guard viewModel.removedItem != nil else { return }
            try? await Task.sleep(for: .seconds(4))
            guard !Task.isCancelled else { return }
            viewModel.handle(.dismissRemoval)
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.removedItem)
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            CartLoadingSkeleton()

        case .empty:
            CartEmptyStateView(onSearch: onSearch)

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
                CartEmptyStateView(onSearch: onSearch)
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

                VStack(spacing: MedsySpacing.sm) {
                    ForEach(items) { item in
                        CartItemRow(
                            item: item,
                            onSelect: { openProductDetails(for: item) },
                            onDecrease: { handleItemEvent(.decreaseQuantity(itemID: item.id)) },
                            onIncrease: { handleItemEvent(.increaseQuantity(itemID: item.id)) },
                            onRemove: { handleItemEvent(.removeItem(itemID: item.id)) }
                        )
                    }
                }

                CartInteractionWarningsView(
                    warnings: viewModel.interactionWarnings,
                    state: viewModel.interactionsState,
                    onRetry: retryInteractions
                )

                if let prescription = viewModel.prescriptions.first {
                    CartPrescriptionAttachmentView(
                        attachment: prescription,
                        onChange: onScanPrescription,
                        onRemove: { removePrescription(id: prescription.id) }
                    )
                } else {
                    CartAddPrescriptionButton(action: onScanPrescription)
                }

                CartPharmacistNoteView(note: viewModel.pharmacistNote) {
                    noteInput = viewModel.pharmacistNote
                    showsNoteEditor = true
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

    private func retryInteractions() {
        Task {
            await viewModel.refreshInteractions(language: languageManager.languageCode)
        }
    }

    private func removePrescription(id: UUID) {
        viewModel.handle(.removePrescriptionByID(id))
    }

    private func handleItemEvent(_ event: CartEvent) {
        viewModel.handle(event)
    }

    private func undoRemoval() {
        viewModel.handle(.undoRemoval)
    }

    private func retry() {
        viewModel.handle(.retry)
    }

    private func continueRequest() {
        guard case let .continueRequest(draft) = viewModel.handle(.continueRequest) else { return }
        onContinue(draft)
    }

    private func openProductDetails(for item: CartDisplayItem) {
        guard let productID = item.productID else { return }
        onProductSelected(String(productID))
    }

}
