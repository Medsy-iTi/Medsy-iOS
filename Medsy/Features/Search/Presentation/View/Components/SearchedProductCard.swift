//
//  SearchedProductCard.swift
//  Medsy
//
//  Created by Shahudaa on 15/07/2026.
//

import SwiftUI

struct SearchedProductCard: View {
	@Binding var product: MedsyProduct
	var onAdd: (() -> Void)? = nil
	var onIncrement: (() -> Void)? = nil
	var onDecrement: (() -> Void)? = nil
	var onToggleFavorite: (() -> Void)? = nil
	var onTap: (() -> Void)?

	@Environment(\.layoutDirection) private var layoutDirection
	@ObservedObject private var appSettings = AppSettings.shared

	private var isRTL: Bool { layoutDirection == .rightToLeft }

	var body: some View {
		HStack(alignment: .top, spacing: MedsySpacing.sm) {
			productImage
			textContent
			actionColumn
		}
		.padding(MedsySpacing.sm)
		.background(
			RoundedRectangle(cornerRadius: MedsyRadius.lg)
				.fill(AppColor.card)
				.overlay(
					RoundedRectangle(cornerRadius: MedsyRadius.lg)
						.stroke(AppColor.border, lineWidth: 1)
				)
		)
		.contentShape(Rectangle())
		.onTapGesture {
			onTap?()
		}
	}

	private var actionColumn: some View {
		VStack(spacing: MedsySpacing.sm) {
			Button {
				product.isFavorite.toggle()
				onToggleFavorite?()
			} label: {
				Image(systemName: product.isFavorite ? "heart.fill" : "heart")
					.foregroundStyle(
						product.isFavorite ? AppColor.danger : AppColor.textSec
					)
			}
			.buttonStyle(.plain)

			Spacer(minLength: 0)

			quantityControl
		}
	}

	private var textContent: some View {
		VStack(
			alignment: .leading,
			spacing: MedsySpacing.xxs
		) {
			Text(product.name)
				.font(MedsyFont.bodyMedium(16))
				.foregroundStyle(AppColor.textPrim)
				.multilineTextAlignment(.leading)
			if !product.dosageInfo.isEmpty {
				Text(product.dosageInfo)
					.font(MedsyFont.caption())
					.foregroundStyle(AppColor.textSec)
					.multilineTextAlignment(.leading)
			}
			Spacer(minLength: MedsySpacing.xs)
			Text("product.price_value".localized(product.price))
				.font(MedsyFont.price())
				.foregroundStyle(AppColor.green)
		}
		.frame(maxWidth: .infinity, alignment: .leading)
	}


	@ViewBuilder
	private var productImage: some View {
		if let imageUrl = product.imageUrl, let url = URL(string: imageUrl) {
			AsyncImage(url: url) { phase in
				switch phase {
					case .success(let image):
						image
							.resizable()
							.scaledToFill()
					case .empty:
						ProgressView()
							.frame(width: 72, height: 72)
					default:
						badgeFallback
				}
			}
			.frame(width: 72, height: 72)
			.clipShape(RoundedRectangle(cornerRadius: MedsyRadius.md))
		} else {
			badgeFallback
		}
	}

	private var badgeFallback: some View {
		RoundedRectangle(cornerRadius: MedsyRadius.md)
			.fill(product.badgeColor.opacity(0.15))
			.frame(width: 72, height: 72)
			.overlay(
				Text(product.badgeText)
					.font(.system(size: 10, weight: .bold))
					.multilineTextAlignment(.center)
					.foregroundStyle(product.badgeColor)
					.padding(4)
			)
	}

	@ViewBuilder
	private var quantityControl: some View {
		if product.quantity > 0 {
			VStack(spacing: MedsySpacing.xs) {
				stepperButton(icon: "plus") {
					product.quantity += 1
					onIncrement?()
				}
				Text("\(product.quantity)")
					.font(MedsyFont.bodyMedium(14))
					.foregroundStyle(AppColor.textPrim)
				stepperButton(icon: "minus") {
					if product.quantity > 0 { product.quantity -= 1 }
					onDecrement?()
				}
			}
		} else {
			stepperButton(icon: "plus") {
				product.quantity = 1
				onAdd?()
			}
		}
	}

	private func stepperButton(icon: String, action: @escaping () -> Void) -> some View {
		Button(action: action) {
			Image(systemName: icon)
				.font(.system(size: 12, weight: .bold))
				.foregroundStyle(.white)
				.frame(width: 26, height: 26)
				.background(Circle().fill(AppColor.green))
		}
		.buttonStyle(.plain)
	}
}
