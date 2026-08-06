//
//  PharmacyChatView+States.swift
//  Medsy-Pharmacy

import SwiftUI

extension PharmacyChatView {
    var loadingState: some View {
        VStack {
            Spacer()
            ProgressView()
                .scaleEffect(1.5)
                .tint(PharmacyColor.primary)
            Text("pharmacy.chatbot.state.loading_history".localized)
                .font(PharmacyColor.sans(15))
                .foregroundColor(PharmacyColor.textSecondary)
                .padding(.top, 16)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    var errorState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(PharmacyColor.warning)
            Text("pharmacy.chatbot.state.error_loading".localized)
                .font(PharmacyColor.sans(16, .semibold))
                .foregroundColor(PharmacyColor.textPrimary)
            Button(action: { viewModel.onAppear() }) {
                Text("pharmacy.chatbot.state.retry".localized)
                    .font(PharmacyColor.sans(15, .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(PharmacyColor.primary)
                    .clipShape(Capsule())
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    var emptyState: some View {
        VStack(spacing: 24) {
            Spacer()
            Image("PharmacyChatEmpty") // Requires asset
                .resizable()
                .scaledToFit()
                .frame(width: 140, height: 140)
            
            VStack(spacing: 8) {
                Text("pharmacy.chatbot.empty.title".localized)
                    .font(PharmacyColor.sans(20, .bold))
                    .foregroundColor(PharmacyColor.textPrimary)
                Text("pharmacy.chatbot.empty.subtitle".localized)
                    .font(PharmacyColor.sans(15))
                    .foregroundColor(PharmacyColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            PharmacyAiChatSuggestionCard { text in
                viewModel.sendSuggestion(text)
            }
            .padding(.top, 16)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
