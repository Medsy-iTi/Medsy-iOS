//
//  MedsyChatInputBar.swift
//  Medsy
//
//  Created by ITI_JETS on 23/07/2026.
//


import SwiftUI

/// Bottom message composer: camera button, text field with mic icon, send button.
struct MedsyChatInputBar: View {
    @Binding var text: String
    var placeholder: String

    var accentColor: Color = MedsyTheme.default.primary
    var fieldBackground: Color = Color(hex: "F1F2F4")

    var onSend: () -> Void = {}
    var onCamera: () -> Void = {}
    var onMic: () -> Void = {}

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

            Button(action: onSend) {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.white)
                    .padding(12)
                    .background(accentColor)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    StatefulPreviewWrapper("") { text in
        MedsyChatInputBar(text: text, placeholder: "Message Medsy AI...")
            .padding()
    }
}