//
//  SearchedProductCard.swift
//  Medsy
//
//  Created by Shahudaa on 15/07/2026.
//

import SwiftUI

struct SearchedProductCard: View {
	@State private var showsRemovalConfirmation = false

	@Binding var product: MedsyProduct
	var onAdd: (() -> Void)? = nil
	var onIncrement: (() -> Void)? = nil
	var onDecrement: (() -> Void)? = nil
	var onToggleFavorite: (() -> Void)? = nil
	var isSelectionMode = false
	var onTap: (() -> Void)?

	var body: some View {
		HStack(alignment: .top, spacing: MedsySpacing.sm) {
			Button {
				onTap?()
			} label: {
				HStack(alignment: .top, spacing: MedsySpacing.sm) {
					productImage
					textContent

					if isSelectionMode {
						Image(systemName: "chevron.forward")
							.font(.footnote.weight(.semibold))
							.foregroundStyle(AppColor.textSec)
							.frame(maxHeight: .infinity)
					}
				}
				.contentShape(Rectangle())
			}
			.buttonStyle(.plain)

			if !isSelectionMode {
				actionColumn
			}
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
		.alert("cart.remove_confirmation.title".localized, isPresented: $showsRemovalConfirmation) {
			Button("common.cancel".localized, role: .cancel) {}
			Button("cart.remove_confirmation.action".localized, role: .destructive) {
				product.quantity = 0
				onDecrement?()
			}
		} message: {
			Text("cart.remove_confirmation.message".localized(product.name))
		}
	}

	private var actionColumn: some View {
		VStack(spacing: MedsySpacing.sm) {
			Button {
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
		MedsyRemoteImage(urlString: product.imageUrl, contentMode: .fit) {
			MedsyBrandImageFallback()
		} failure: {
			MedsyBrandImageFallback()
		}
		.frame(width: 72, height: 72)
		.background(AppColor.surface)
		.clipShape(RoundedRectangle(cornerRadius: MedsyRadius.md))
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
					if product.quantity == 1 {
						showsRemovalConfirmation = true
					} else {
						product.quantity -= 1
						onDecrement?()
					}
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
