//
//  PrescriptionCoordinatorView.swift
//  Medsy
//
//  Created by Ahmed Elkady on 18/07/2026.
//

import SwiftUI

@MainActor
struct PrescriptionCoordinatorView: View {
    @State private var viewModel: PrescriptionViewModel

    private let onExit: () -> Void
    private let onOpenSearch: () -> Void
    private let onOpenCart: () -> Void

    init(
        mockOutcome: PrescriptionMockOutcome = .success,
        onExit: @escaping () -> Void,
        onOpenSearch: @escaping () -> Void,
        onOpenCart: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: PrescriptionViewModel(mockOutcome: mockOutcome))
        self.onExit = onExit
        self.onOpenSearch = onOpenSearch
        self.onOpenCart = onOpenCart
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .upload:
                PrescriptionUploadView(
                    onCamera: { send(.selectCamera) },
                    onGallery: { send(.selectGallery) },
                    onBack: { send(.back) }
                )
            case .preview:
                PrescriptionPreviewView(
                    onContinue: { send(.continueFromPreview) },
                    onChangeImage: { send(.changeImage) },
                    onDelete: { send(.deleteImage) },
                    onBack: { send(.back) }
                )
            case .reading:
                PrescriptionReadingView(onCancel: { send(.cancelReading) })
            case let .review(medicines):
                PrescriptionReviewView(
                    medicines: medicines,
                    onAddToCart: { send(.addToCart) },
                    onBack: { send(.back) }
                )
            case let .result(result):
                PrescriptionResultView(
                    result: result,
                    primaryAction: { send(primaryEvent(for: result)) },
                    secondaryAction: { send(secondaryEvent(for: result)) },
                    onBack: { send(.back) }
                )
            }
        }
    }

    private func send(_ event: PrescriptionEvent) {
        guard let effect = viewModel.handle(event) else { return }

        switch effect {
        case .exit:
            onExit()
        case .openSearch:
            onOpenSearch()
        case .openCart:
            onOpenCart()
        }
    }

    private func primaryEvent(for result: PrescriptionFlowResult) -> PrescriptionEvent {
        switch result {
        case .added:
            .viewCart
        case .uploadFailed:
            .retry
        case .readingFailed, .noMedicines:
            .changeImage
        }
    }

    private func secondaryEvent(for result: PrescriptionFlowResult) -> PrescriptionEvent {
        switch result {
        case .added:
            .backHome
        case .uploadFailed:
            .changeImage
        case .readingFailed:
            .continueWithoutReading
        case .noMedicines:
            .addMedicineManually
        }
    }
}
