//
//  MedsyChatInputBar.swift
//  Medsy
//
//  Created by ITI_JETS on 23/07/2026.
//


import SwiftUI


struct MedsyChatInputBar: View {
    @Binding var text: String
    var placeholder: String

    var accentColor: Color = MedsyTheme.default.primary
    var fieldBackground: Color = MedsyTheme.default.surface

    var onSend: () -> Void = {}
    var onCamera: () -> Void = {}
    var onMic: () -> Void = {}
    var disabled: Bool = false

    var body: some View {
        HStack(spacing: 10) {
            Button(action: onCamera) {
                Image(systemName: "camera")
                    .foregroundColor(.gray)
                    .padding(10)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            HStack {
                TextField(placeholder, text: $text)
                Button(action: onMic) {
                    Image(systemName: "mic")
                        .foregroundColor(accentColor)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(fieldBackground)
            .clipShape(Capsule())

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

#Preview {
    StatefulPreviewWrapper("") { text in
        MedsyChatInputBar(text: text, placeholder: "Message Medsy AI...")
            .padding()
    }
}
