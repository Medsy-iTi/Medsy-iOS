//
//  CompleteRequestCoordinatorView.swift
//  Medsy
//
//  Created by Ehab Salah on 24/07/2026.
//

import SwiftUI

@MainActor
struct CompleteRequestCoordinatorView: View {
    @State private var showsLocationPicker = false
    @State private var viewModel: CompleteRequestViewModel
    private let factory: CompleteRequestFactory
    private let onBack: () -> Void
    private let onCompleted: () -> Void
    
    init(
        draft: CompleteRequestDraft,
        factory: CompleteRequestFactory = DIContainer.shared.resolve(CompleteRequestFactory.self),
        clearCart: @escaping () async -> Bool,
        onBack: @escaping () -> Void,
        onCompleted: @escaping () -> Void
    ) {
        self.factory = factory
        self.onBack = onBack
        self.onCompleted = onCompleted
        viewModel = factory.makeViewModel(draft: draft,onSubmit: { _ in await clearCart() })
    }
    
    var body: some View {
        CompleteRequestView(
            viewModel: viewModel,
            onBack: onBack,
            onChangeLocation: { showsLocationPicker = true },
            onCompleted: onCompleted
        )
        .fullScreenCover(isPresented: $showsLocationPicker) {
            CompleteRequestLocationPickerView(
                viewModel: factory.makeLocationPickerViewModel(
                    initialLocation: viewModel.deliveryLocation,
                    initialAddress: viewModel.savedAddress
                ),
                onCancel: { showsLocationPicker = false },
                onConfirm: { location in
                    viewModel.confirmLocation(location)
                    showsLocationPicker = false
                }
            )
        }
    }
}
