//
//  MedsyChatView+States.swift
//  Medsy
//

import SwiftUI

extension MedsyChatView {

    // MARK: - Empty state — suggestion grid
    var emptyState: some View {
        VStack(spacing: MedsySpacing.md) {
            // Logo
            ZStack {
                RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous)
                    .fill(AppColor.primaryLight)
                Image(systemName: "sparkles")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(theme.primary)
            }
            .frame(width: 72, height: 72)

            Text("chatbot.empty.title".localized)
                .font(MedsyFont.title())
                .foregroundColor(AppColor.textPrim)

            Text("chatbot.empty.subtitle".localized)
                .font(MedsyFont.body())
                .foregroundColor(AppColor.textSec)
                .multilineTextAlignment(.center)
                .padding(.horizontal, MedsySpacing.xl)

            // 2-column suggestion grid with equal-height rows
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10)
                ],
                spacing: 10
            ) {
                ForEach(suggestions) { suggestion in
                    AiChatSuggestionCard(
                        iconName: suggestion.iconName,
                        title: suggestion.title,
                        subtitle: suggestion.subtitle,
                        accentColor: theme.primary,
                        action: {
                            viewModel.sendSuggestion(suggestion.prompt)
                        }
                    )
                    .frame(height: 120)
                }
            }
            .padding(.top, MedsySpacing.sm)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }

    /// Only intents that the backend actually handles are listed here.
    /// Matches AIChatIntent cases: symptomAdvice, medicineRequest, doctorSpecialization,
    /// emergency, categoryBrowse, setReminder
    private var suggestions: [AiSuggestion] {
        [
            AiSuggestion(
                id: 0,
                iconName: "thermometer.medium",
                title: "chatbot.suggestion.symptoms".localized,
                subtitle: "chatbot.suggestion.symptoms.subtitle".localized,
                prompt: "chatbot.suggestion.symptoms.prompt".localized
            ),
            AiSuggestion(
                id: 1,
                iconName: "cart.badge.plus",
                title: "chatbot.suggestion.order".localized,
                subtitle: "chatbot.suggestion.order.subtitle".localized,
                prompt: "chatbot.suggestion.order.prompt".localized
            ),
            AiSuggestion(
                id: 2,
                iconName: "stethoscope",
                title: "chatbot.suggestion.doctor".localized,
                subtitle: "chatbot.suggestion.doctor.subtitle".localized,
                prompt: "chatbot.suggestion.doctor.prompt".localized
            ),
            AiSuggestion(
                id: 3,
                iconName: "exclamationmark.triangle.fill",
                title: "chatbot.suggestion.emergency".localized,
                subtitle: "chatbot.suggestion.emergency.subtitle".localized,
                prompt: "chatbot.suggestion.emergency.prompt".localized
            ),
            AiSuggestion(
                id: 4,
                iconName: "square.grid.2x2",
                title: "chatbot.suggestion.browse".localized,
                subtitle: "chatbot.suggestion.browse.subtitle".localized,
                prompt: "chatbot.suggestion.browse.prompt".localized
            ),
            AiSuggestion(
                id: 5,
                iconName: "bell.badge",
                title: "chatbot.suggestion.reminder".localized,
                subtitle: "chatbot.suggestion.reminder.subtitle".localized,
                prompt: "chatbot.suggestion.reminder.prompt".localized
            )
        ]
    }

    // MARK: - History states
    var historyLoadingIndicator: some View {
        HStack(spacing: MedsySpacing.sm) {
            ProgressView()
                .scaleEffect(0.8)
            Text("chatbot.history.loading".localized)
                .font(MedsyFont.caption())
                .foregroundColor(AppColor.textSec)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical, MedsySpacing.sm)
    }

    var historyFailedBanner: some View {
        Text("chatbot.history.failed".localized)
            .font(MedsyFont.caption())
            .foregroundColor(theme.warning)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, MedsySpacing.xs)
    }

    // MARK: - Typing indicator
    var typingIndicator: some View {
        HStack(alignment: .top, spacing: MedsySpacing.xs) {
            aiAvatar
            TypingDotsView(color: theme.primary)
                .padding(.horizontal, MedsySpacing.md)
                .padding(.vertical, MedsySpacing.sm)
                .background(AppColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .medsyCardShadow()
            Spacer(minLength: 40)
        }
    }

    // MARK: - Error banner
    func errorBanner(message: String) -> some View {
        HStack(spacing: MedsySpacing.xs) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(theme.danger)
            Text(message)
                .font(MedsyFont.caption())
                .foregroundColor(theme.danger)
                .frame(maxWidth: .infinity, alignment: .leading)
            Button("common.retry".localized) {
                withAnimation { viewModel.retryLastFailedMessage() }
            }
            .font(MedsyFont.caption())
            .foregroundColor(theme.danger)
        }
        .padding(MedsySpacing.sm)
        .background(theme.dangerLight)
        .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: MedsyRadius.md, style: .continuous)
                .stroke(theme.danger.opacity(0.25))
        )
    }

    // MARK: - Disclaimer banner
    var disclaimerBanner: some View {
        MedsyDisclaimerBanner(
            text: "chatbot.disclaimer".localized,
            backgroundColor: theme.warningLight,
            textColor: theme.warning
        )
    }

    // MARK: - Input bar (mic + camera + send)
    var inputBar: some View {
        VStack(spacing: 0) {
            Divider().background(AppColor.border)
            MedsyChatInputBar(
                text: $viewModel.inputText,
                placeholder: "chatbot.input.placeholder".localized,
                accentColor: viewModel.isSendEnabled ? theme.primary : AppColor.textSec,
                fieldBackground: AppColor.surface,
                isRecording: viewModel.isRecording,
                onSend: {
                    if viewModel.selectedImage != nil {
                        viewModel.sendWithImage()
                    } else {
                        viewModel.sendText()
                    }
                },
                onCamera: { showImagePicker = true },
                onMic: { viewModel.toggleRecording() },
                disabled: !viewModel.isSendEnabled
            )
            .padding(.horizontal, MedsySpacing.sm)
            .padding(.vertical, MedsySpacing.sm)
        }
        .background(AppColor.surface)
    }
}

// MARK: - Suggestion model
struct AiSuggestion: Identifiable {
    let id: Int
    let iconName: String
    let title: String
    let subtitle: String
    let prompt: String
}
