//
//  MedsyChatView+States.swift
//  Medsy
//

import SwiftUI

extension MedsyChatView {
    var emptyState: some View {
        VStack(spacing: MedsySpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous)
                    .fill(AppColor.primaryLight)
                Image(systemName: "plus")
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
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }

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

    func errorBanner(message: String) -> some View {
        HStack(spacing: MedsySpacing.xs) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(theme.danger)

            Text(message)
                .font(MedsyFont.caption())
                .foregroundColor(theme.danger)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button("chatbot.error.dismiss".localized) {
                withAnimation { viewModel.dismissError() }
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

    var disclaimerBanner: some View {
        MedsyDisclaimerBanner(
            text:            "chatbot.disclaimer".localized,
            backgroundColor: theme.warningLight,
            textColor:       theme.warning
        )
    }

    var inputBar: some View {
        VStack(spacing: 0) {
            Divider().background(AppColor.border)
            MedsyChatInputBar(
                text:            $viewModel.inputText,
                placeholder:     "chatbot.input.placeholder".localized,
                accentColor:     viewModel.isLoading ? AppColor.textSec : theme.primary,
                fieldBackground: AppColor.surface,
                onSend:          { viewModel.sendMessage() },
                disabled:        viewModel.isLoading
            )
            .padding(.horizontal, MedsySpacing.sm)
            .padding(.vertical, MedsySpacing.sm)
        }
        .background(AppColor.surface)
    }
}
