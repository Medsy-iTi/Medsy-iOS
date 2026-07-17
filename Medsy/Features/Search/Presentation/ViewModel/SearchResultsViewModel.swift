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
	@Published var errorMessage: String?


	@Published var selectedSort: ProductSort? = nil {
		didSet { guard oldValue != selectedSort else { return }; load() }
	}


	@Published var selectedCategory: String? = nil {
		didSet { guard oldValue != selectedCategory else { return }; load() }
	}

	private let useCase: SearchProductsUseCaseProtocol
	private let languageManager: LanguageManager

	private let pageSize = 20
	private var currentPage = 0
	private var isLastPage = false
	private var isLoadingPage = false
	private var loadTask: Task<Void, Never>?
	private var cancellables = Set<AnyCancellable>()

	init(
		query: String,
		useCase: SearchProductsUseCaseProtocol = DIContainer.shared.resolve(SearchProductsUseCaseProtocol.self),
		languageManager: LanguageManager = .shared
	) {
		self.query = query
		self.useCase = useCase
		self.languageManager = languageManager


		$query
			.dropFirst()
			.debounce(for: .milliseconds(400), scheduler: DispatchQueue.main)
			.removeDuplicates()
			.sink { [weak self] _ in
				self?.load()
			}
			.store(in: &cancellables)
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
		selectedSort = nil
		selectedCategory = nil
		state = .empty
	}

	// MARK: – Helpers


	func isSortActive(_ sort: ProductSort) -> Bool {
		selectedSort == sort
	}


	func toggleSort(_ sort: ProductSort) {
		selectedSort = (selectedSort == sort) ? nil : sort
	}

	// MARK: – Private

	private func fetch(reset: Bool) async {
		guard !isLoadingPage else { return }
		isLoadingPage = true
		defer { isLoadingPage = false }

		do {
			let sort: [ProductSort] = selectedSort.map { [$0] } ?? []
			let result = try await useCase.execute(
				keyword: query,
				page: currentPage,
				size: pageSize,
				sort: sort,
				lang: languageManager.currentLanguage.rawValue
			)
			print(languageManager.currentLanguage.rawValue)
			guard !Task.isCancelled else { return }

			var mapped = result.items.map {
				ProductPresentationMapper.map($0, isRTL: languageManager.isRTL)
			}

			if let category = selectedCategory {
				mapped = mapped.filter { $0.categoryName.caseInsensitiveCompare(category) == .orderedSame }
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
