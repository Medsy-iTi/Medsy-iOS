//
//  SearchResultsViewModel.swift
//  Medsy
//
//  Created by Shahudaa on 15/07/2026.
//

import Foundation
import Combine


@MainActor
final class SearchResultsViewModel: ObservableObject {
    @Published var query: String
    @Published var state: SearchResultsState = .loading
    @Published var products: [MedsyProduct] = []
    @Published var selectedFilter: String = "relevant"

    init(query: String) {
        self.query = query
    }

    func load() {
        state = .loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            guard let self else { return }
            self.products = Self.mockResults
            self.state = self.products.isEmpty ? .empty : .loaded
        }
    }

    func clearSearch() {
        query = ""
        state = .empty
    }

    static let mockResults: [MedsyProduct] = [
        MedsyProduct(id: "1", name: "بانادول إكسترا", subtitle: "500 مجم · 24 قرص", price: 68, badgeText: "Panadol Extra", badgeColor: .red, quantity: 2),
        MedsyProduct(id: "2", name: "بانادول سينوس", subtitle: "20 قرص", price: 52, badgeText: "Panadol Sinus", badgeColor: .blue),
        MedsyProduct(id: "3", name: "بانادول للأطفال", subtitle: "120 مجم · 60 مل", price: 45, badgeText: "Panadol", badgeColor: .pink),
        MedsyProduct(id: "4", name: "بانادول كولد آند فلو", subtitle: "من 12 سنة · 24 قرص", price: 60, badgeText: "Panadol Cold&Flu", badgeColor: .teal),
        MedsyProduct(id: "5", name: "بانادول العادي", subtitle: "500 مجم · 20 قرص", price: 35, badgeText: "Panadol", badgeColor: .red),
    ]
}

