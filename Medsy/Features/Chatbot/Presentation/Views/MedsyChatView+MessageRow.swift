//
//  MedsyChatView+MessageRow.swift
//  Medsy
//

import SwiftUI

extension MedsyChatView {
    @ViewBuilder
    func messageRow(_ message: ChatMessage) -> some View {
        switch message.sender {
        case .user:
            userBubble(message.text)

        case .ai:
            switch message.customCard {
            case .catalogResult(let sources):
                aiBubbleRich(message.text) {
                    CatalogSourcesCard(
                        sources: sources,
                        onAddToCart: { source in 
                            let item = CartDisplayItem(
                                id: UUID().uuidString,
                                productID: Int64(source.product.id),
                                name: source.product.productName ?? source.product.name,
                                dosageInfo: source.product.strength ?? "",
                                unitPrice: source.product.price,
                                quantity: 1,
                                imageUrl: source.product.imageUrl
                            )
                            cartViewModel.handle(.addItem(item))
                        },
                        onDetails: { source in viewModel.onNavigateToDetails?(String(source.product.id)) }
                    )
                }

            case .medicineSuggestion(let medicine):
                aiBubbleRich(message.text) {
                    MedsyProductCard(
                        eyebrow:             "chatbot.demo.product.eyebrow.otc".localized,
                        name:                medicine.name,
                        subtitle:            medicine.dosage,
                        price:               "EGP \(Int(medicine.price))",
                        primaryButtonTitle:  "chatbot.action.add_to_cart".localized,
                        secondaryButtonTitle: "chatbot.action.details".localized,
                        accentColor:         theme.primary
                    )
                }

            case .emergency(let title, let description, _):
                aiBubbleRich(message.text) {
                    MedsyEmergencyAlertCard(
                        iconName:            "exclamationmark.triangle.fill",
                        title:               title,
                        message:             description,
                        primaryActionTitle:  "chatbot.demo.interaction.action_title".localized,
                        primaryActionSubtitle: "chatbot.demo.interaction.action_subtitle".localized,
                        secondaryActions:    [],
                        accentColor:         theme.danger,
                        backgroundColor:     theme.dangerLight
                    )
                }

            default:
                if !message.text.isEmpty {
                    aiBubble(message.text)
                }
            }
        }
    }

    private func userBubble(_ text: String) -> some View {
        MedsyChatBubble(
            text:                text,
            isUser:              true,
            userBubbleColor:     theme.primary,
            userTextColor:       .white,
            assistantBubbleColor: AppColor.surface,
            assistantTextColor:  AppColor.textPrim
        )
    }

    private func aiBubble(_ text: String) -> some View {
        HStack(alignment: .top, spacing: MedsySpacing.xs) {
            aiAvatar

            if !text.isEmpty {
                Text(text)
                    .font(MedsyFont.body(15))
                    .foregroundColor(AppColor.textPrim)
                    .padding(.horizontal, MedsySpacing.md)
                    .padding(.vertical, MedsySpacing.sm)
                    .background(AppColor.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .medsyCardShadow()

                Spacer(minLength: 40)
            }
        }
    }

    private func aiBubbleRich<Card: View>(_ text: String, @ViewBuilder card: () -> Card) -> some View {
        HStack(alignment: .top, spacing: MedsySpacing.xs) {
            aiAvatar

            VStack(alignment: .leading, spacing: MedsySpacing.xs) {
                if !text.isEmpty {
                    Text(text)
                        .font(MedsyFont.body(15))
                        .foregroundColor(AppColor.textPrim)
                        .padding(.horizontal, MedsySpacing.md)
                        .padding(.vertical, MedsySpacing.sm)
                        .background(AppColor.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .medsyCardShadow()
                }
                card()
            }

            Spacer(minLength: 16)
        }
    }

    var aiAvatar: some View {
        ZStack {
            RoundedRectangle(cornerRadius: MedsyRadius.sm, style: .continuous)
                .fill(theme.primary)
            Image(systemName: "plus")
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
                        title:           title,
                        style:           .outline,
                        accentColor:     theme.primary,
                        backgroundColor: AppColor.surface
                    )
                }
            }
        }
    }
}
