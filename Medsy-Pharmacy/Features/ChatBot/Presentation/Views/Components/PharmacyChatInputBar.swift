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
    var disabled: Bool = false

    @FocusState private var isFocused: Bool
    @State private var micPulse: Bool = false

    var body: some View {
        HStack(spacing: 10) {
            // Camera button
            Button(action: onCamera) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 18))
                    .foregroundColor(PharmacyColor.primary)
                    .frame(width: 40, height: 40)
                    .background(PharmacyColor.primarySoft)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .disabled(disabled)

            // Text field with mic inside
            HStack(spacing: 8) {
                TextField(placeholder, text: $text, axis: .vertical)
                    .font(PharmacyColor.sans(15))
                    .focused($isFocused)
                    .lineLimit(1...5)
                    .submitLabel(.send)
                    .onSubmit { if isSendEnabled { onSend() } }
                    .disabled(disabled)

                // Mic button
                Button(action: onMic) {
                    Image(systemName: isRecording ? "waveform" : "mic.fill")
                        .font(.system(size: 16))
                        .foregroundColor(isRecording ? PharmacyColor.danger : PharmacyColor.textSecondary)
                        .scaleEffect(isRecording && micPulse ? 1.25 : 1.0)
                        .animation(
                            isRecording
                                ? .easeInOut(duration: 0.55).repeatForever(autoreverses: true)
                                : .default,
                            value: micPulse
                        )
                }
                .buttonStyle(.plain)
                .onChange(of: isRecording) { _, recording in
                    micPulse = recording
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(PharmacyColor.mutedSurface)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(PharmacyColor.border, lineWidth: 1)
            )

            // Send button
            Button(action: { if isSendEnabled { onSend() } }) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(isSendEnabled ? PharmacyColor.primary : PharmacyColor.border)
                    .clipShape(Circle())
                    .animation(.easeInOut(duration: 0.15), value: isSendEnabled)
            }
            .buttonStyle(.plain)
            .disabled(!isSendEnabled)
        }
    }
}
