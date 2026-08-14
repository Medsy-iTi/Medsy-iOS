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
        HStack(alignment: .bottom, spacing: 10) {
            // Camera button
            Button(action: onCamera) {
                Image(systemName: "camera")
                    .foregroundColor(AppColor.textSec)
                    .padding(10)
                    .background(AppColor.surfaceContainer)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            // Text field + mic
            HStack(alignment: .bottom) {
                TextField(placeholder, text: $text, axis: .vertical)
                    .lineLimit(1...5)
                    .foregroundStyle(AppColor.textPrim)
                    .localizedTextInput()
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
                .padding(.bottom, 2)
                .onChange(of: isRecording) { _, recording in
                    micPulse = recording
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(fieldBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

            // Send button
            Button(action: { if !disabled { onSend() } }) {
                Image(systemName: "paperplane.fill")
                    .flipsForRightToLeftLayoutDirection(true)
                    .foregroundColor(disabled ? AppColor.textSec : AppColor.white)
                    .padding(12)
                    .background(disabled ? AppColor.surfaceContainerHighest : accentColor)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .disabled(disabled)
        }
    }
}
