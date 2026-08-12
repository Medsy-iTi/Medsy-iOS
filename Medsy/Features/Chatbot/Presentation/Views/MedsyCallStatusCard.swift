//
//  MedsyCallStatusCard.swift
//  Medsy
//
//  Created by ITI_JETS on 23/07/2026.
//


import SwiftUI


struct MedsyCallStatusCard: View {
    var title: String
    var subtitle: String

    var accentColor: Color = MedsyTheme.default.primary
    var liveDotColor: Color = .green
    var endButtonColor: Color = .red

    var primaryButtonTitle: String = "End call"
    var secondaryButtonTitle: String = "Take over call"

    var onPrimaryTap: () -> Void = {}
    var onSecondaryTap: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                ZStack {
                    Circle().fill(accentColor.opacity(0.12))
                    Image(systemName: "phone.fill")
                        .foregroundColor(accentColor)
                }
                .frame(width: 36, height: 36)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(title)
                            .font(.system(size: 14, weight: .semibold))
                        Circle().fill(liveDotColor).frame(width: 6, height: 6)
                    }
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }

            HStack(spacing: 10) {
                Button(action: onPrimaryTap) {
                    Text(primaryButtonTitle)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(endButtonColor)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .overlay(Capsule().stroke(endButtonColor.opacity(0.4)))
                }
                .buttonStyle(.plain)

                Button(action: onSecondaryTap) {
                    Text(secondaryButtonTitle)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .overlay(Capsule().stroke(Color.gray.opacity(0.3)))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    MedsyCallStatusCard(
        title: "Calling El Ezaby Pharmacy...",
        subtitle: "Asking about Panadol Extra 500 mg availability"
    )
    .padding()
}
