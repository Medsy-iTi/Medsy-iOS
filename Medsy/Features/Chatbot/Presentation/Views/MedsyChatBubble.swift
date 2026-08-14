//
//  MedsyChatBubble.swift
//  Medsy
//
//  Created by ITI_JETS on 23/07/2026.
//


import SwiftUI


struct MedsyChatBubble: View {
    let text: String
    let isUser: Bool

    var userBubbleColor: Color = MedsyTheme.default.primary
    var userTextColor: Color = .white
    var assistantBubbleColor: Color = MedsyTheme.default.surface
    var assistantTextColor: Color = AppColor.textPrim

    var body: some View {
        HStack {
            if isUser { Spacer(minLength: 40) }

            Text(text)
                .font(.system(size: 15))
                .foregroundColor(isUser ? userTextColor : assistantTextColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(isUser ? userBubbleColor : assistantBubbleColor)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(isUser ? .clear : AppColor.border.opacity(0.7), lineWidth: 1)
                }

            if !isUser { Spacer(minLength: 40) }
        }
    }
}

#Preview {
    VStack(spacing: 10) {
        MedsyChatBubble(text: "My father has chest pain spreading to his left arm and he's sweating a lot", isUser: true)
        MedsyChatBubble(text: "Sorry to hear that. A few quick questions — does the pain feel like pressure?", isUser: false)
    }
    .padding()
}
