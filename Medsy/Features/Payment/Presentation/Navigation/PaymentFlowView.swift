//
//  PaymentFlowView.swift
//  Medsy
//
//  Created by Ahmed Elkady on 02/08/2026.
//

import SwiftUI

struct PaymentFlowView: View {
    @State private var viewModel: PaymentFlowViewModel
    let onCompleted: () -> Void
    let onViewOrder: () -> Void

    init(
        viewModel: PaymentFlowViewModel,
        onCompleted: @escaping () -> Void,
        onViewOrder: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onCompleted = onCompleted
        self.onViewOrder = onViewOrder
    }

    var body: some View {
        PaymentStatusView(
            status: viewModel.state.statusPresentation,
            isPrimaryActionLoading: viewModel.state.isBusy,
            isPrimaryActionDisabled: viewModel.state.isBusy,
            onPrimaryAction: handlePrimaryAction,
            onSecondaryAction: onViewOrder
        )
        .task {
            await viewModel.handle(.start)
        }
    }

    private func handlePrimaryAction() {
        switch viewModel.state {
        case .success:
            onCompleted()
        case .failure, .cancelled:
            Task { await viewModel.handle(.retry) }
        case .processing, .expired:
            onViewOrder()
        case .idle, .loading, .presenting:
            break
        }
    }
}
