//
//  PharmacyChatRootView.swift
//  Medsy-Pharmacy

import SwiftUI

@MainActor
struct PharmacyChatRootView: View {
    @State private var viewModel: PharmacyAiChatViewModel
    
    init(factory: PharmacyAiChatViewModelFactory) {
        self._viewModel = State(wrappedValue: factory.makeViewModel())
    }
    
    var body: some View {
        PharmacyChatView(viewModel: viewModel)
    }
}

protocol PharmacyAiChatViewModelFactory: Sendable {
    @MainActor func makeViewModel() -> PharmacyAiChatViewModel
}
