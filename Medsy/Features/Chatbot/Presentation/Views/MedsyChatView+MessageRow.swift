//
//  MedsyChatView+MessageRow.swift
//  Medsy
//

import SwiftUI

extension MedsyChatView {

    @ViewBuilder
    func messageRow(_ message: AiChatMessage) -> some View {
        switch message.role {
        case .user:
            VStack(alignment: .trailing, spacing: MedsySpacing.xs) {
                userBubble(message)
                if message.isRetryable {
                    Button("common.retry".localized) {
                        viewModel.retryMessage(id: message.id)
                    }
                    .font(MedsyFont.caption())
                    .foregroundColor(theme.danger)
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)

        case .assistant:
            if message.isTyping { EmptyView() } // shown via typingIndicator state
            else { assistantRow(message) }

        case .unknown:
            EmptyView()
        }
    }

    @ViewBuilder
    private func assistantRow(_ message: AiChatMessage) -> some View {
        let intent = message.intent ?? .other
        HStack(alignment: .top, spacing: MedsySpacing.xs) {
            aiAvatar
            VStack(alignment: .leading, spacing: MedsySpacing.xs) {
                // Answer bubble (markdown)
                if !message.text.isEmpty {
                    answerBubble(message.text, intent: intent)
                }
                // Disclaimer row
                if let disclaimer = message.disclaimer {
                    AiChatDisclaimerRow(text: disclaimer)
                }
                // Intent-specific cards
                intentCards(message, intent: intent)
            }
            Spacer(minLength: 16)
        }
    }

    @ViewBuilder
    private func answerBubble(_ text: String, intent: AIChatIntent) -> some View {
        let isReminder = intent == .setReminder
        if isReminder {
            AiChatReminderBubble(text: text)
        } else {
            AiChatMarkdownText(text: text)
                .font(MedsyFont.body(15))
                .foregroundColor(AppColor.textPrim)
                .padding(.horizontal, MedsySpacing.md)
                .padding(.vertical, MedsySpacing.sm)
                .background(AppColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .medsyCardShadow()
        }
    }

    @ViewBuilder
    private func intentCards(_ message: AiChatMessage, intent: AIChatIntent) -> some View {
        switch intent {
        case .medicineRequest, .addToCart where message.action == nil:
            // Show product list when we have products but no completed cart action
            if !message.products.isEmpty {
                productStack(message.products)
            }

        case .addToCart:
            if let action = message.action, action.type == .addedToCart {
                AiChatCartSuccessCard(
                    quantity: action.quantity ?? 1,
                    cartItemCount: action.cartItemCount ?? 0,
                    onViewCart: {
                        // Force the CartViewModel to reload from the server before
                        // navigating so the cart screen shows the backend-added item.
                        cartViewModel.handle(.retry)
                        viewModel.onOpenCart?()
                    }
                )
                .padding(.top, MedsySpacing.xs)
                .padding(.bottom, 12)
            } else if !message.products.isEmpty {
                productStack(message.products)
            }

        case .symptomAdvice:
            // Show top 2 medicine suggestions
            let topTwo = Array(message.products.prefix(2))
            if !topTwo.isEmpty {
                productStack(topTwo)
            }
            // Also show doctor specialization chips if returned alongside
            if !message.doctorSpecializations.isEmpty {
                AiChatSpecializationCard(
                    specializations: message.doctorSpecializations,
                    accentColor: theme.primary
                )
                .padding(.top, MedsySpacing.xs)
                .padding(.bottom, 12)
            }

        case .emergency:
            if !message.emergencyNumbers.isEmpty {
                AiChatEmergencyCard(numbers: message.emergencyNumbers)
                    .padding(.top, MedsySpacing.xs)
                    .padding(.bottom, 12)
            }

        case .doctorSpecialization:
            if !message.doctorSpecializations.isEmpty {
                AiChatSpecializationCard(
                    specializations: message.doctorSpecializations,
                    accentColor: theme.primary
                )
                .padding(.top, MedsySpacing.xs)
                .padding(.bottom, 12)
            }

        case .categoryBrowse:
            AiChatCategoryCard(categories: message.categories) { cat in
                viewModel.onOpenCategory?(cat.id, cat.name)
            }
            .padding(.top, MedsySpacing.xs)
            .padding(.bottom, 12)

        case .createRequest:
            // Always show the confirm card when intent is createRequest
            if let action = message.action, action.type == .createRequest {
                AiChatConfirmRequestCard(onConfirm: {
                    viewModel.confirmRequest(action: action, fallbackProducts: message.products)
                })
                .padding(.top, MedsySpacing.xs)
                .padding(.bottom, 12)
            }

        case .setReminder:
            // Show a confirmation chip with the scheduled times when available
            if let reminder = message.reminder {
                AiChatReminderConfirmCard(
                    reminder: reminder,
                    onViewReminders: { viewModel.onOpenReminders?() }
                )
                .padding(.top, MedsySpacing.xs)
                .padding(.bottom, 12)
            }

        default:
            EmptyView()
        }
    }

    private func productStack(_ products: [AIChatProduct]) -> some View {
        VStack(spacing: MedsySpacing.sm) {
            ForEach(products, id: \.id) { product in
                AiChatProductRow(
                    product: product,
                    onAddToCart: { p in
                        // The PRODUCT CARD add-to-cart button calls the cart API directly
                        let item = CartDisplayItem(
                            id: UUID().uuidString,
                            productID: Int64(p.id),
                            name: p.productName ?? p.name,
                            dosageInfo: p.strength ?? "",
                            unitPrice: p.price,
                            quantity: 1,
                            imageUrl: p.imageURL
                        )
                        cartViewModel.handle(.addItem(item))
                    },
                    onDetails: { p in
                        viewModel.onOpenProductDetails?(p.id)
                    }
                )
                .medsyCardShadow()
            }
        }
        .padding(.top, MedsySpacing.xs)
        .padding(.bottom, 12)
    }

    private func userBubble(_ message: AiChatMessage) -> some View {
        VStack(alignment: .trailing, spacing: MedsySpacing.xs) {
            // If this message has an attached image, render a real thumbnail
            if let data = message.attachedImageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 180, height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous)
                            .stroke(theme.primary.opacity(0.2), lineWidth: 1)
                    )
                    .medsyCardShadow()
            }
            // Show text caption only when there's actual text (not the placeholder label)
            let caption = message.text
            let isPlaceholder = caption == "📷 Image" || caption == "📷 صورة"
            if !caption.isEmpty && !(message.attachedImageData != nil && isPlaceholder) {
                MedsyChatBubble(
                    text: caption,
                    isUser: true,
                    userBubbleColor: theme.primary,
                    userTextColor: .white,
                    assistantBubbleColor: AppColor.surface,
                    assistantTextColor: AppColor.textPrim
                )
            }
        }
    }

    var aiAvatar: some View {
        ZStack {
            RoundedRectangle(cornerRadius: MedsyRadius.sm, style: .continuous)
                .fill(theme.primary)
            Image(systemName: "sparkles")
                .foregroundColor(.white)
                .font(.system(size: 11, weight: .bold))
        }
        .frame(width: 28, height: 28)
    }

    func chipRow(_ titles: [String]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: MedsySpacing.xs) {
                ForEach(titles, id: \.self) { title in
                    MedsyQuickActionChip(
                        title: title,
                        style: .outline,
                        accentColor: theme.primary,
                        backgroundColor: AppColor.surface
                    )
                }
            }
        }
    }
}
