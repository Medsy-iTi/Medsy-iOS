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
	@Published private(set) var isLoadingNextPage = false


	@Published var selectedSort: ProductSort? = nil {
		didSet { guard oldValue != selectedSort else { return }; load() }
	}


	@Published var selectedCategory: Category? = nil {
		didSet { guard oldValue != selectedCategory else { return }; load() }
	}
    
    @Published var selectedCompany: String? = nil {
        didSet { guard oldValue != selectedCompany else { return }; load() }
    }
    
    var availableCompanies: [String] {
        [
            "company.lilly".localized,
            "company.novartis".localized,
            "company.roche".localized,
            "company.pfizer".localized,
            "company.astrazeneca".localized,
            "company.novonordisk".localized,
            "company.eva_pharm".localized
        ]
    }
    @Published var categories: [Category] = []

	private let useCase: SearchProductsUseCaseProtocol
    private let getCategoriesUseCase: GetCategoriesUseCase
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
        getCategoriesUseCase: GetCategoriesUseCase = DIContainer.shared.resolve(GetCategoriesUseCase.self),
		languageManager: LanguageManager = .shared
	) {
		self.query = query
		self.useCase = useCase
        self.getCategoriesUseCase = getCategoriesUseCase
		self.languageManager = languageManager

        Task {
            if let result = try? await getCategoriesUseCase.execute(page: 0, size: 100, lang: languageManager.currentLanguage.rawValue) {
                self.categories = result.items
            }
        }


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
		isLoadingNextPage = false
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
        selectedCompany = nil
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
		if !reset { isLoadingNextPage = true }
		defer {
			isLoadingPage = false
			isLoadingNextPage = false
		}

		do {
			let sort: [ProductSort] = selectedSort.map { [$0] } ?? []
			let result = try await useCase.execute(
				keyword: query,
                categoryId: selectedCategory?.id,
				page: currentPage,
				size: pageSize,
				sort: sort,
				lang: languageManager.currentLanguage.rawValue,
                company: selectedCompany
			)
			print(languageManager.currentLanguage.rawValue)
			guard !Task.isCancelled else { return }

			let mapped = result.items.map {
				ProductPresentationMapper.map($0, isRTL: languageManager.isRTL)
			}

			let uniqueMapped = mapped.filter { newProduct in
				!products.contains { $0.id == newProduct.id }
			}

			products = reset ? mapped : products + uniqueMapped
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
