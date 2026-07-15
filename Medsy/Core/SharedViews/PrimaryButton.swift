//
//  PrimaryButton.swift
//  Medsy
//
//  Created by Ehab Salah on 15/07/2026.
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    var systemImage: String?
    var isLoading = false
    var isDisabled = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(title)
                        .font(.headline)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    if let systemImage {
                        HStack {
                            Spacer()
                            Image(systemName: systemImage)
                                .font(.body.weight(.semibold))
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .padding(.horizontal, 18)
        }
        .buttonStyle(PrimaryButtonStyle())
        .disabled(isDisabled || isLoading)
        .accessibilityLabel(title)
    }
}

private struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(AppColor.green)
            )
            .opacity(isEnabled ? 1 : 0.45)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}

#Preview {
    VStack(spacing: 16) {
        PrimaryButton(title: "Continue", systemImage: "chevron.forward") {}
        PrimaryButton(title: "Continue", isLoading: true) {}
        PrimaryButton(title: "Continue", isDisabled: true) {}
    }
    .padding()
}
