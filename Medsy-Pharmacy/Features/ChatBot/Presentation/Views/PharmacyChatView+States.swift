//
//  PharmacyChatView+States.swift
//  Medsy-Pharmacy

import SwiftUI

extension PharmacyChatView {

    // MARK: - Loading state
    var loadingState: some View {
        VStack(spacing: PharmacySpacing.md) {
            Spacer()
            ProgressView()
                .scaleEffect(1.4)
                .tint(PharmacyColor.primary)
            Text("pharmacy.chatbot.state.loading_history".localized)
                .font(PharmacyColor.sans(15))
                .foregroundColor(PharmacyColor.textSecondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Error / history-load failed state
    var errorState: some View {
        VStack(spacing: PharmacySpacing.md) {
            Spacer()
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 44))
                .foregroundColor(PharmacyColor.warning)
            Text("pharmacy.chatbot.state.error_loading".localized)
                .font(PharmacyColor.sans(16, .semibold))
                .foregroundColor(PharmacyColor.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, PharmacySpacing.xl)
            Button(action: { viewModel.onAppear() }) {
                Text("pharmacy.chatbot.state.retry".localized)
                    .font(PharmacyColor.sans(15, .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 12)
                    .background(PharmacyColor.primary)
                    .clipShape(Capsule())
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Empty state — sparkles avatar + 2-column suggestion grid
    var emptyState: some View {
        VStack(spacing: PharmacySpacing.md) {
            // Avatar
            ZStack {
                RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous)
                    .fill(PharmacyColor.primarySoft)
                Image(systemName: "sparkles")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(PharmacyColor.primary)
            }
            .frame(width: 72, height: 72)

            Text("pharmacy.chatbot.empty.title".localized)
                .font(PharmacyColor.sans(20, .bold))
                .foregroundColor(PharmacyColor.textPrimary)

            Text("pharmacy.chatbot.empty.subtitle".localized)
                .font(PharmacyColor.sans(15))
                .foregroundColor(PharmacyColor.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, PharmacySpacing.xl)

            // 2-column suggestion grid
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10)
                ],
                spacing: 10
            ) {
                ForEach(pharmacySuggestions) { suggestion in
                    PharmacyAiSuggestionChip(
                        iconName: suggestion.iconName,
                        title: suggestion.title,
                        subtitle: suggestion.subtitle
                    ) {
                        viewModel.sendSuggestion(suggestion.prompt)
                    }
                    .frame(height: 110)
                }
            }
            .padding(.top, PharmacySpacing.sm)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }

    private var pharmacySuggestions: [PharmacyAiSuggestion] {
        [
            PharmacyAiSuggestion(
                id: 0,
                iconName: "chart.bar.fill",
                title: "pharmacy.chatbot.suggestion.performance.title".localized,
                subtitle: "pharmacy.chatbot.suggestion.performance.subtitle".localized,
                prompt: "pharmacy.chatbot.suggestion.performance".localized
            ),
            PharmacyAiSuggestion(
                id: 1,
                iconName: "pills.fill",
                title: "pharmacy.chatbot.suggestion.drug_info.title".localized,
                subtitle: "pharmacy.chatbot.suggestion.drug_info.subtitle".localized,
                prompt: "pharmacy.chatbot.suggestion.drug_info".localized
            ),
            PharmacyAiSuggestion(
                id: 2,
                iconName: "exclamationmark.triangle.fill",
                title: "pharmacy.chatbot.suggestion.interactions.title".localized,
                subtitle: "pharmacy.chatbot.suggestion.interactions.subtitle".localized,
                prompt: "pharmacy.chatbot.suggestion.interactions".localized
            ),
            PharmacyAiSuggestion(
                id: 3,
                iconName: "arrow.2.squarepath",
                title: "pharmacy.chatbot.suggestion.alternative.title".localized,
                subtitle: "pharmacy.chatbot.suggestion.alternative.subtitle".localized,
                prompt: "pharmacy.chatbot.suggestion.alternative".localized
            )
        ]
    }

    // MARK: - Typing indicator (shown in scroll list)
    var typingIndicator: some View {
        HStack(alignment: .top, spacing: PharmacySpacing.xs) {
            aiChatAvatar
            PharmacyTypingDotsView()
                .padding(.horizontal, PharmacySpacing.md)
                .padding(.vertical, PharmacySpacing.sm)
                .background(PharmacyColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
            Spacer(minLength: 40)
        }
    }

    // MARK: - Disclaimer banner (shown at top of message list)
    var disclaimerBanner: some View {
        PharmacyAiChatDisclaimerRow(text: "pharmacy.chatbot.disclaimer".localized)
    }

    // MARK: - History loading indicator (inline in scroll list)
    var historyLoadingIndicator: some View {
        HStack(spacing: PharmacySpacing.sm) {
            ProgressView()
                .scaleEffect(0.8)
                .tint(PharmacyColor.primary)
            Text("pharmacy.chatbot.state.loading_history".localized)
                .font(PharmacyColor.sans(13))
                .foregroundColor(PharmacyColor.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical, PharmacySpacing.sm)
    }

    var historyFailedBanner: some View {
        Text("pharmacy.chatbot.state.error_loading".localized)
            .font(PharmacyColor.sans(13))
            .foregroundColor(PharmacyColor.warning)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, PharmacySpacing.xs)
    }

    // MARK: - Floating error banner above input bar
    func errorBanner(message: String) -> some View {
        HStack(spacing: PharmacySpacing.xs) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(PharmacyColor.danger)
            Text(message)
                .font(PharmacyColor.sans(13))
                .foregroundColor(PharmacyColor.danger)
                .frame(maxWidth: .infinity, alignment: .leading)
            Button("pharmacy.chatbot.state.retry".localized) {
                withAnimation { viewModel.dismissError() }
            }
            .font(PharmacyColor.sans(13, .semibold))
            .foregroundColor(PharmacyColor.danger)
        }
        .padding(PharmacySpacing.sm)
        .background(PharmacyColor.danger.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous)
                .stroke(PharmacyColor.danger.opacity(0.25))
        )
    }

    // MARK: - AI avatar for message rows
    var aiChatAvatar: some View {
        ZStack {
            RoundedRectangle(cornerRadius: PharmacyRadius.sm, style: .continuous)
                .fill(PharmacyColor.primary)
            Image(systemName: "sparkles")
                .foregroundColor(.white)
                .font(.system(size: 11, weight: .bold))
        }
        .frame(width: 28, height: 28)
    }
}

// MARK: - Suggestion model

struct PharmacyAiSuggestion: Identifiable {
    let id: Int
    let iconName: String
    let title: String
    let subtitle: String
    let prompt: String
}

// MARK: - Suggestion chip card

struct PharmacyAiSuggestionChip: View {
    let iconName: String
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 6) {
                Image(systemName: iconName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(PharmacyColor.primary)
                    .frame(width: 36, height: 36)
                    .background(PharmacyColor.primarySoft)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                Spacer()

                Text(title)
                    .font(PharmacyColor.sans(14, .semibold))
                    .foregroundColor(PharmacyColor.textPrimary)
                    .lineLimit(1)

                Text(subtitle)
                    .font(PharmacyColor.sans(12))
                    .foregroundColor(PharmacyColor.textSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .padding(PharmacySpacing.sm)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .background(PharmacyColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous)
                    .stroke(PharmacyColor.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
