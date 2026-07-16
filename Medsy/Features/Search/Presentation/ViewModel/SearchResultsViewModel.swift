//
//  SearchResultsViewModel.swift
//  Medsy
//

import Foundation
import Combine

@MainActor
final class SearchResultsViewModel: ObservableObject {

	@Published var query: String
	@Published var state: SearchResultsState = .loading
	@Published var products: [MedsyProduct] = []
	@Published var selectedFilter: String = "relevant"
	@Published var errorMessage: String?

	private let useCase: SearchProductsUseCaseProtocol
	private let languageManager: LanguageManager

	private let pageSize = 20
	private var currentPage = 0
	private var isLastPage = false
	private var isLoadingPage = false
	private var loadTask: Task<Void, Never>?

	init(
		query: String,
		useCase: SearchProductsUseCaseProtocol = DIContainer.shared.resolve(SearchProductsUseCaseProtocol.self),
		languageManager: LanguageManager = .shared
	) {
		self.query = query
		self.useCase = useCase
		self.languageManager = languageManager
	}


	func load() {
		loadTask?.cancel()
		currentPage = 0
		isLastPage = false
		state = .loading
		loadTask = Task { await fetch(reset: true) }
	}


	func loadNextPageIfNeeded(currentItem: MedsyProduct) {
		guard
			currentItem.id == products.last?.id,
			!isLastPage,
			!isLoadingPage
		else { return }

		loadTask = Task { await fetch(reset: false) }
	}

	func clearSearch() {
		loadTask?.cancel()
		query = ""
		products = []
		state = .empty
	}

	private func fetch(reset: Bool) async {
		guard !isLoadingPage else { return }
		isLoadingPage = true
		defer { isLoadingPage = false }

		do {
			let result = try await useCase.execute(
				keyword: query,
				page: currentPage,
				size: pageSize,
				sort: []
			)

			guard !Task.isCancelled else { return }

			let mapped = result.items.map {
				ProductPresentationMapper.map($0, isRTL: languageManager.isRTL)
			}

			products = reset ? mapped : products + mapped
			isLastPage = result.isLast ?? (mapped.count < pageSize)
			currentPage += 1
			state = products.isEmpty ? .empty : .loaded

		} catch is CancellationError {

		} catch let error as NetworkError {
			errorMessage = error.errorDescription
			state = .noConnection
		} catch {
			errorMessage = error.localizedDescription
			state = .noConnection
		}
	}
}
