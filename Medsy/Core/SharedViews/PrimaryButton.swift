//
//  PrimaryButton.swift
//  Medsy
//
//  Created by Ehab Salah on 15/07/2026.
//

import SwiftUI

enum MedsyButtonStyleKind {
	case primary
	case secondary
}

struct PrimaryButton: View {
	let title: String
	var systemImage: String?
	var style: MedsyButtonStyleKind = .primary
	var isLoading = false
	var isDisabled = false
	let action: () -> Void
	@ObservedObject private var appSettings = AppSettings.shared

	var body: some View {
		Button(action: action) {
			ZStack {
				if isLoading {
					ProgressView()
						.tint(style == .primary ? .white : AppColor.green)
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
		.buttonStyle(PrimaryButtonStyle(kind: style))
		.disabled(isDisabled || isLoading)
		.accessibilityLabel(title)
	}
}

private struct PrimaryButtonStyle: ButtonStyle {
	let kind: MedsyButtonStyleKind
	@Environment(\.isEnabled) private var isEnabled
	@ObservedObject private var appSettings = AppSettings.shared

	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.foregroundStyle(kind == .primary ? .white : AppColor.green)
			.background(
				RoundedRectangle(cornerRadius: 14, style: .continuous)
					.fill(kind == .primary ? AppColor.green : AppColor.card)
			)
			.overlay(
				RoundedRectangle(cornerRadius: 14, style: .continuous)
					.stroke(kind == .secondary ? AppColor.green : .clear, lineWidth: 1.5)
			)
			.opacity(isEnabled ? 1 : 0.45)
			.scaleEffect(configuration.isPressed ? 0.98 : 1)
			.animation(.easeOut(duration: 0.16), value: configuration.isPressed)
	}
}

#Preview {
	VStack(spacing: 16) {
		PrimaryButton(title: "Continue", systemImage: "chevron.forward") {}
		PrimaryButton(title: "Consult a Pharmacist", systemImage: "bubble.left.and.bubble.right", style: .secondary) {}
		PrimaryButton(title: "Continue", isLoading: true) {}
		PrimaryButton(title: "Continue", isDisabled: true) {}
	}
	.padding()
}
