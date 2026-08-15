//
//  AddressPickerScreen.swift
//  Medsy
//
//  Created by Shahudaa on 20/07/2026.
//


import SwiftUI
import MapKit

struct AddressPickerScreen: View {

	@State private var viewModel: AddressPickerViewModel

	init(viewModel: AddressPickerViewModel) {
		_viewModel = State(wrappedValue: viewModel)
	}

	var body: some View {
		ZStack {
			ProfileStyle.background
				.ignoresSafeArea()

			VStack(spacing: 0) {
				MedsyNavBar(title: "address.title".localized)

				searchField
				locationPermissionBanner

				if !viewModel.searchResults.isEmpty {
					suggestionsList
				} else {
					mapSection
					addressField
					confirmButton
				}
			}
		}
		.onAppear {
			viewModel.requestLocationPermission()
			viewModel.resolveInitialLocationIfNeeded()
		}
	}


	@ViewBuilder
	private var locationPermissionBanner: some View {
		if let message = viewModel.locationPermissionMessage {
			HStack(spacing: 10) {
				Image(systemName: "location.slash")
					.font(.system(size: 13, weight: .bold))
					.foregroundStyle(ProfileStyle.red)

				Text(message)
					.font(.system(size: 12, weight: .semibold))
					.foregroundStyle(ProfileStyle.primaryText)
					.lineLimit(2)

				Spacer(minLength: 0)
			}
			.padding(.horizontal, 14)
			.padding(.vertical, 10)
			.background(ProfileStyle.redBackground)
			.clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
			.overlay {
				RoundedRectangle(cornerRadius: 14, style: .continuous)
					.stroke(ProfileStyle.redBorder, lineWidth: 1)
			}
			.padding(.horizontal, 20)
			.padding(.bottom, 12)
		}
	}


	private var searchField: some View {
		CustomTextField(
			title: "address.search_placeholder".localized,
			type: .address,
			text: $viewModel.searchText
		)
		.padding(.horizontal, 20)
		.padding(.top, 12)
		.padding(.bottom, viewModel.searchResults.isEmpty ? 12 : 0)
		.onChange(of: viewModel.searchText) {
			viewModel.scheduleSearch()
		}
		.onSubmit {
			Task { await viewModel.performSearch() }
		}
	}

	private var suggestionsList: some View {
		ScrollView(showsIndicators: false) {
			VStack(spacing: 0) {
				ForEach(viewModel.annotatedItems) { annotated in
					Button {
						viewModel.selectSearchResult(annotated.mapItem)
					} label: {
						suggestionRow(annotated.mapItem)
					}
					.buttonStyle(.plain)

					if annotated.id != viewModel.annotatedItems.last?.id {
						Divider()
							.background(ProfileStyle.border)
							.padding(.leading, 56)
					}
				}
			}
			.background(ProfileStyle.card)
			.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
			.overlay {
				RoundedRectangle(cornerRadius: 16, style: .continuous)
					.stroke(ProfileStyle.border, lineWidth: 1)
			}
			.padding(.horizontal, 20)
			.padding(.top, 12)
		}
	}

	private func suggestionRow(_ item: MKMapItem) -> some View {
		HStack(spacing: 12) {
			RoundedRectangle(cornerRadius: 12, style: .continuous)
				.fill(ProfileStyle.green.opacity(0.16))
				.frame(width: 34, height: 34)
				.overlay {
					Image(systemName: "mappin")
						.font(.system(size: 14, weight: .semibold))
						.foregroundStyle(ProfileStyle.green)
				}

			VStack(alignment: .leading, spacing: 2) {
				Text(item.name ?? "")
					.font(.system(size: 14, weight: .semibold))
					.foregroundStyle(ProfileStyle.primaryText)
					.lineLimit(1)

				if let subtitle = item.placemark.title {
					Text(subtitle)
						.font(.system(size: 12, weight: .medium))
						.foregroundStyle(ProfileStyle.secondaryText)
						.lineLimit(1)
				}
			}

			Spacer(minLength: 0)
		}
		.padding(.horizontal, 14)
		.padding(.vertical, 12)
	}


	private var mapSection: some View {
		MapReader { proxy in
			Map(position: $viewModel.cameraPosition) {
				if let pickedCoordinate = viewModel.pickedCoordinate {
					Annotation("", coordinate: pickedCoordinate) {
						Image(systemName: "mappin.circle.fill")
							.font(.system(size: 30, weight: .semibold))
							.foregroundStyle(ProfileStyle.red)
					}
				}
			}
			.onTapGesture { screenPoint in
				if let coordinate = proxy.convert(screenPoint, from: .local) {
					viewModel.selectPin(at: coordinate)
				}
			}
			.onMapCameraChange(frequency: .onEnd) { context in
				viewModel.updateRegion(context.region)
			}
			.overlay(alignment: .top) {
				if viewModel.isResolvingAddress {
					Text("address.resolving".localized)
						.font(.system(size: 12, weight: .semibold))
						.foregroundStyle(ProfileStyle.primaryText)
						.padding(.horizontal, 12)
						.padding(.vertical, 6)
						.background(ProfileStyle.card)
						.clipShape(Capsule())
						.overlay {
							Capsule().stroke(ProfileStyle.border, lineWidth: 1)
						}
						.padding(.top, 10)
				}
			}
			.overlay(alignment: .trailing) {
				zoomControls
					.padding(.trailing, 10)
			}
		}
		.clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
		.overlay {
			RoundedRectangle(cornerRadius: 20, style: .continuous)
				.stroke(ProfileStyle.border, lineWidth: 1)
		}
		.padding(.horizontal, 20)
		.frame(height: 420)
	}

	private var zoomControls: some View {
		VStack(spacing: 1) {
			zoomButton(systemImage: "plus") {
				viewModel.zoomIn()
			}
			Divider()
				.frame(width: 34)
				.background(ProfileStyle.border)
			zoomButton(systemImage: "minus") {
				viewModel.zoomOut()
			}
		}
		.background(ProfileStyle.card)
		.clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
		.overlay {
			RoundedRectangle(cornerRadius: 10, style: .continuous)
				.stroke(ProfileStyle.border, lineWidth: 1)
		}
	}

	private func zoomButton(systemImage: String, action: @escaping () -> Void) -> some View {
		Button(action: action) {
			Image(systemName: systemImage)
				.font(.system(size: 14, weight: .bold))
				.foregroundStyle(ProfileStyle.primaryText)
				.frame(width: 34, height: 34)
		}
		.buttonStyle(.plain)
	}


	private var addressField: some View {
		CustomTextField(
			title: "profile.home_address.placeholder".localized,
			type: .address,
			text: $viewModel.addressText
		)
		.padding(.horizontal, 20)
		.padding(.top, 16)
	}

	private var confirmButton: some View {
		PrimaryButton(
			title: "address.confirm".localized,
			isDisabled: !viewModel.hasPickedLocation
			|| viewModel.addressText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
		) {
			viewModel.confirmSelection()
		}
		.padding(.horizontal, 20)
		.padding(.top, 16)
		.padding(.bottom, 24)
	}
}
