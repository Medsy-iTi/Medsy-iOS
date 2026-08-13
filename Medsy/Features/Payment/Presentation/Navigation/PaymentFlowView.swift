//
//  PaymentFlowView.swift
//  Medsy
//
//  Created by Ahmed Elkady on 02/08/2026.
//

import SwiftUI

struct PaymentFlowView: View {
    @Environment(\.scenePhase) private var scenePhase
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
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            guard viewModel.state == .processing || viewModel.state == .cancelled else { return }
            Task { await viewModel.handle(.refreshStatus) }
        }
        .onDisappear {
            Task { await viewModel.handle(.stop) }
        }
    }

    private func handlePrimaryAction() {
        switch viewModel.state {
        case .success:
            onCompleted()
        case .failure, .cancelled:
            Task { await viewModel.handle(.retry) }
        case .processing:
            Task { await viewModel.handle(.refreshStatus) }
        case .expired:
            onViewOrder()
        case .idle, .loading, .presenting:
            break
        }
    }
}
