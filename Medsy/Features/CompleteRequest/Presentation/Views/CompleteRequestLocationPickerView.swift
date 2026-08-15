//
//  CompleteRequestLocationPickerView.swift
//  Medsy
//
//  Created by Ehab Salah on 24/07/2026.
//

import MapKit
import SwiftUI

struct CompleteRequestLocationPickerView: View {
    @State private var viewModel: CompleteRequestLocationPickerViewModel
    let onCancel: () -> Void
    let onConfirm: (CompleteRequestLocation) -> Void

    init(
        viewModel: CompleteRequestLocationPickerViewModel,
        onCancel: @escaping () -> Void,
        onConfirm: @escaping (CompleteRequestLocation) -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onCancel = onCancel
        self.onConfirm = onConfirm
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        VStack(spacing: 0) {
            MedsyNavBar(title: "complete_request.location.title".localized)

            VStack(spacing: MedsySpacing.sm) {
                searchField

                if !viewModel.searchResults.isEmpty {
                    searchResults
                }

                map

                if let message = viewModel.locationErrorMessage {
                    Text(message)
                        .font(MedsyFont.caption())
                        .foregroundStyle(AppColor.danger)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                if !viewModel.addressText.isEmpty {
                    Label(viewModel.addressText, systemImage: "mappin.and.ellipse")
                        .font(MedsyFont.body())
                        .foregroundStyle(AppColor.textPrim)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(MedsySpacing.md)
                        .background(AppColor.card)
                        .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.md))
                }

                PrimaryButton(
                    title: "address.confirm".localized,
                    isLoading: viewModel.isResolvingAddress,
                    isDisabled: !viewModel.canConfirm
                ) {
                    guard let location = viewModel.confirmLocation() else { return }
                    onConfirm(location)
                }
            }
            .padding(.horizontal, MedsySpacing.md)
            .padding(.bottom, MedsySpacing.md)
        }
        .background(AppColor.bg.ignoresSafeArea())
        .task {
            await viewModel.resolveInitialAddressIfNeeded()
        }
    }

    private var searchField: some View {
        HStack(spacing: MedsySpacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppColor.textSec)

            TextField("address.search_placeholder".localized, text: $viewModel.searchText)
                .textInputAutocapitalization(.words)
                .localizedTextInput()
                .submitLabel(.search)
                .onChange(of: viewModel.searchText) {
                    viewModel.scheduleSearch()
                }

            if viewModel.isSearching {
                ProgressView()
            }
        }
        .padding(.horizontal, MedsySpacing.md)
        .frame(height: 48)
        .background(AppColor.card)
        .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.md))
        .overlay {
            RoundedRectangle(cornerRadius: MedsyRadius.md)
                .stroke(AppColor.border, lineWidth: 1)
        }
    }

    private var searchResults: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(Array(viewModel.searchResults.enumerated()), id: \.offset) { _, item in
                    Button {
                        viewModel.selectSearchResult(item)
                    } label: {
                        VStack(alignment: .leading, spacing: MedsySpacing.xxs) {
                            Text(item.name ?? item.placemark.title ?? "")
                                .font(MedsyFont.bodyMedium())
                                .foregroundStyle(AppColor.textPrim)
                            if let details = item.placemark.title, details != item.name {
                                Text(details)
                                    .font(MedsyFont.caption())
                                    .foregroundStyle(AppColor.textSec)
                                    .lineLimit(2)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(MedsySpacing.sm)
                    }
                    .buttonStyle(.plain)
                    Divider().background(AppColor.border)
                }
            }
        }
        .frame(maxHeight: 180)
        .background(AppColor.card)
        .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.md))
    }

    private var map: some View {
        MapReader { proxy in
            Map(position: $viewModel.cameraPosition) {
                if let coordinate = viewModel.selectedCoordinate {
                    Marker(
                        "complete_request.location.pin".localized,
                        coordinate: coordinate
                    )
                    .tint(AppColor.green)
                }
            }
            .onTapGesture { point in
                guard let coordinate = proxy.convert(point, from: .local) else { return }
                viewModel.selectPin(at: coordinate)
            }
            .overlay(alignment: .topTrailing) {
                Button {
                    Task { await viewModel.useCurrentLocation() }
                } label: {
                    Image(systemName: "location.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppColor.green)
                        .frame(width: 44, height: 44)
                        .background(AppColor.card)
                        .clipShape(Circle())
                        .medsyCardShadow()
                }
                .accessibilityLabel("address.current_location".localized)
                .padding(MedsySpacing.sm)
            }
            .overlay {
                if viewModel.isResolvingAddress {
                    ProgressView()
                        .padding(MedsySpacing.md)
                        .background(AppColor.card)
                        .clipShape(Circle())
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.lg))
        .overlay {
            RoundedRectangle(cornerRadius: MedsyRadius.lg)
                .stroke(AppColor.border, lineWidth: 1)
        }
        .frame(maxHeight: .infinity)
    }
}
