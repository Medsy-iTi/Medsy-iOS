//
//  MedsyChatInputBar.swift
//  Medsy
//

import SwiftUI

struct MedsyChatInputBar: View {
    @Binding var text: String
    var placeholder: String
    var accentColor: Color = MedsyTheme.default.primary
    var fieldBackground: Color = MedsyTheme.default.surface
    var isRecording: Bool = false
    var onSend: () -> Void = {}
    var onCamera: () -> Void = {}
    var onMic: () -> Void = {}
    var disabled: Bool = false

    @State private var micPulse: Bool = false

    var body: some View {
        HStack(spacing: 10) {
            // Camera button
            Button(action: onCamera) {
                Image(systemName: "camera")
                    .foregroundColor(.gray)
                    .padding(10)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            // Text field + mic
            HStack {
                TextField(placeholder, text: $text)
                    .submitLabel(.send)
                    .onSubmit { if !disabled { onSend() } }

                Button(action: onMic) {
                    Image(systemName: isRecording ? "waveform" : "mic")
                        .foregroundColor(isRecording ? .red : accentColor)
                        .scaleEffect(isRecording && micPulse ? 1.2 : 1.0)
                        .animation(
                            isRecording
                                ? .easeInOut(duration: 0.6).repeatForever(autoreverses: true)
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
            .background(fieldBackground)
            .clipShape(Capsule())

            // Send button
            Button(action: { if !disabled { onSend() } }) {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.white)
                    .padding(12)
                    .background(disabled ? Color.gray.opacity(0.4) : accentColor)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .disabled(disabled)
        }
    }
}
