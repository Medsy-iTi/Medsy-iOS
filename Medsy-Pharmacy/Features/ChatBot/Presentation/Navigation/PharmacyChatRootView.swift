//
//  PharmacyChatRootView.swift
//  Medsy-Pharmacy

import SwiftUI

struct PharmacyChatRootView: View {
    let factory: PharmacyAiChatViewModelFactory
    @State private var viewModel: PharmacyAiChatViewModel?
    
    init(factory: PharmacyAiChatViewModelFactory) {
        self.factory = factory
    }
    
    var body: some View {
        Group {
            if let viewModel = viewModel {
                PharmacyChatView(viewModel: viewModel)
            } else {
                ProgressView()
            }
        }
        .task {
            if viewModel == nil {
                viewModel = factory.makeViewModel()
            }
        }
    }
}

protocol PharmacyAiChatViewModelFactory: Sendable {
    @MainActor func makeViewModel() -> PharmacyAiChatViewModel
}
