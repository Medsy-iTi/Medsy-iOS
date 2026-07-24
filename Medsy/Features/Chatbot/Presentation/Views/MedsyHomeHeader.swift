//
//  MedsyHomeHeader.swift
//  Medsy
//
//  Created by ITI_JETS on 23/07/2026.
//


import SwiftUI

/// The "Hi Omar, how are you feeling today?" hero header on the Medsy AI home tab.
struct MedsyHomeHeader: View {
    var iconName: String = "sparkles"
    var greeting: String
    var subtitle: String

    var accentColor: Color = MedsyTheme.default.primary

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(accentColor)
                Image(systemName: iconName)
                    .foregroundColor(.white)
                    .font(.system(size: 26))
            }
            .frame(width: 60, height: 60)

            Text(greeting)
                .font(.system(size: 20, weight: .bold))
                .multilineTextAlignment(.center)

            Text(subtitle)
                .font(.system(size: 13))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    MedsyHomeHeader(
        greeting: "Hi Omar, how are you feeling today?",
        subtitle: "Tell me your symptoms, ask about a medicine, or send a photo of a prescription."
    )
    .padding()
}