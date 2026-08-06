//
//  PharmacyChatView+MessageRow.swift
//  Medsy-Pharmacy

import SwiftUI

extension PharmacyChatView {
    @ViewBuilder
    func messageRow(for message: AiChatMessage) -> some View {
        if message.role == .user {
            userMessageRow(message)
        } else {
            assistantMessageRow(message)
        }
    }

    private func userMessageRow(_ message: AiChatMessage) -> some View {
        HStack(alignment: .bottom) {
            Spacer(minLength: 40)

            VStack(alignment: .trailing, spacing: 4) {
                if !message.text.isEmpty {
                    Text(message.text)
                        .font(PharmacyColor.sans(15))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(PharmacyColor.primary)
                        .clipShape(ChatBubbleShape(isUser: true))
                }

                if message.isRetryable {
                    Button(action: { viewModel.retryMessage(id: message.id) }) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.clockwise")
                            Text("pharmacy.chatbot.state.retry".localized)
                        }
                        .font(PharmacyColor.sans(12, .semibold))
                        .foregroundColor(PharmacyColor.danger)
                    }
                    .padding(.top, 2)
                }
            }
        }
    }

    private func assistantMessageRow(_ message: AiChatMessage) -> some View {
        HStack(alignment: .top, spacing: 10) {
            aiChatAvatar

            VStack(alignment: .leading, spacing: 12) {
                if message.isTyping {
                    PharmacyTypingDotsView()
                        .padding(.horizontal, PharmacySpacing.md)
                        .padding(.vertical, PharmacySpacing.sm)
                        .background(PharmacyColor.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
                } else {
                    if !message.text.isEmpty {
                        PharmacyAiChatMarkdownText(text: message.text)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(PharmacyColor.surface)
                            .clipShape(ChatBubbleShape(isUser: false))
                            .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
                    }

                    // Render Intent Cards
                    Group {
                        if !message.doctorSpecializations.isEmpty {
                            PharmacyAiChatSpecializationCard(specializations: message.doctorSpecializations)
                        }

                        if !message.emergencyNumbers.isEmpty {
                            PharmacyAiChatEmergencyCard(numbers: message.emergencyNumbers)
                        }

                        if !message.products.isEmpty {
                            ForEach(message.products) { product in
                                PharmacyAiChatProductRow(
                                    product: product
                                )
                            }
                        }

                        if !message.alternatives.isEmpty {
                            Text("pharmacy.chatbot.alternatives".localized)
                                .font(PharmacyColor.sans(14, .bold))
                                .foregroundColor(PharmacyColor.textSecondary)
                                .padding(.top, 8)
                            ForEach(message.alternatives) { product in
                                PharmacyAiChatProductRow(
                                    product: product
                                )
                            }
                        }

                        if !message.pharmacistRankings.isEmpty {
                            ForEach(message.pharmacistRankings, id: \.metric) { ranking in
                                PharmacyAiChatPharmacistRankingCard(ranking: ranking)
                            }
                        }

                        if let disclaimer = message.disclaimer {
                            PharmacyAiChatDisclaimerRow(text: disclaimer)
                        }
                    }
                }
            }
            Spacer(minLength: 40)
        }
    }
}

struct ChatBubbleShape: Shape {
    var isUser: Bool

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [
                .topLeft,
                .topRight,
                isUser ? .bottomLeft : .bottomRight
            ],
            cornerRadii: CGSize(width: 16, height: 16)
        )
        return Path(path.cgPath)
    }
}
