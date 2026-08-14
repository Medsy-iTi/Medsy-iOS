//
//  PharmacyChatInputBar.swift
//  Medsy-Pharmacy
//
//  Input bar for the pharmacy AI chatbot.
//  Contains: camera button | text field with mic | send button.
//  Mirrors MedsyChatInputBar using Pharmacy theme tokens.

import SwiftUI

struct PharmacyChatInputBar: View {
    @Binding var text: String
    var placeholder: String
    var isRecording: Bool = false
    var isSendEnabled: Bool = false
    var onSend: () -> Void = {}
    var onCamera: () -> Void = {}
    var onMic: () -> Void = {}
    var quickActions: [AiAnalyticsPreset] = []
    var onQuickAction: (AiAnalyticsPreset) -> Void = { _ in }
    var disabled: Bool = false

    @FocusState private var isFocused: Bool
    @State private var micPulse: Bool = false

    var body: some View {
        VStack(spacing: 8) {
            // Quick Actions Scroll
            if !quickActions.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(quickActions, id: \.self) { preset in
                            Button(action: { onQuickAction(preset) }) {
                                Text(presetLabel(for: preset))
                                    .font(PharmacyColor.sans(13, .medium))
                                    .foregroundColor(PharmacyColor.primary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(PharmacyColor.primarySoft)
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule().stroke(PharmacyColor.primary.opacity(0.3), lineWidth: 1)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                }
            }
            
            HStack(alignment: .bottom, spacing: 10) {
                // Camera button
                Button(action: onCamera) {
                Image(systemName: "camera")
                    .font(.system(size: 16))
                    .foregroundColor(PharmacyColor.textSecondary)
                    .padding(10)
                    .background(PharmacyColor.border)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .disabled(disabled)

            // Text field with mic inside
            HStack(alignment: .bottom) {
                TextField(placeholder, text: $text, axis: .vertical)
                    .font(PharmacyColor.sans(15))
                    .focused($isFocused)
                    .lineLimit(1...5)
                    .submitLabel(.send)
                    .onSubmit { if isSendEnabled { onSend() } }
                    .disabled(disabled)

                // Mic button
                Button(action: onMic) {
                    Image(systemName: isRecording ? "waveform" : "mic")
                        .font(.system(size: 16))
                        .foregroundColor(isRecording ? PharmacyColor.danger : PharmacyColor.primary)
                        .scaleEffect(isRecording && micPulse ? 1.2 : 1.0)
                        .animation(
                            isRecording
                                ? .easeInOut(duration: 0.6).repeatForever(autoreverses: true)
                                : .default,
                            value: micPulse
                        )
                }
                .buttonStyle(.plain)
                .padding(.bottom, 2)
                .onChange(of: isRecording) { _, recording in
                    micPulse = recording
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(PharmacyColor.mutedSurface)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

            // Send button
            Button(action: { if isSendEnabled { onSend() } }) {
                Image(systemName: "paperplane.fill")
                    .flipsForRightToLeftLayoutDirection(true)
                    .font(.system(size: 14))
                    .foregroundColor(isSendEnabled ? .white : PharmacyColor.textSecondary)
                    .padding(12)
                    .background(isSendEnabled ? PharmacyColor.primary : PharmacyColor.border)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .disabled(!isSendEnabled)
        }
    }
    }
    
    private func presetLabel(for preset: AiAnalyticsPreset) -> String {
        switch preset {
        case .pharmacyMonthOverview: return "pharmacy.chatbot.analytics.preset.month_overview".localized
        case .pharmacyMonthAcceptance: return "pharmacy.chatbot.analytics.preset.month_acceptance".localized
        case .pharmacyMonthTopEmployee: return "pharmacy.chatbot.analytics.preset.top_employee".localized
        case .pharmacyMonthLargestOrder: return "pharmacy.chatbot.analytics.preset.largest_order".localized
        case .selfMonthOverview: return "pharmacy.chatbot.analytics.preset.self_overview".localized
        case .selfMonthOrders: return "pharmacy.chatbot.analytics.preset.self_orders".localized
        }
    }
}
