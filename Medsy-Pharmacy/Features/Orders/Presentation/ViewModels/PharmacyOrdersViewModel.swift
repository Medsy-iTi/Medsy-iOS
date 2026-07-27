//
//  PharmacyOrdersViewModel.swift
//  Medsy
//
//  Created by Shahudaa on 21/07/2026.
//

import Foundation
import Observation

enum PharmacyOrdersResolutionError: Error, LocalizedError {
	case noPharmacy

	var errorDescription: String? {
		switch self {
			case .noPharmacy:
				return "pharmacy.orders.no_pharmacy".localized
		}
	}
}

@MainActor
@Observable
final class PharmacyOrdersViewModel {
	enum LoadState: Equatable {
		case idle
		case loading
		case loaded
		case failed(String)
	}

	var selectedFilter: PharmacyOrdersFilter = .all
	var searchText = ""
	private(set) var orders: [PharmacyOrderListItem] = []
	private(set) var originalOrders: [PharmacyOrder] = []
	private(set) var loadState: LoadState = .idle
	private(set) var isLoadingNextPage = false

	private let fetchOrdersUseCase: FetchPharmacyOrdersUseCaseProtocol
	private let getProfileUseCase: GetPharmacyProfileUseCaseProtocol
	private let appSettings: PharmacyAppSettings
	private let identityProvider: PharmacyIdentityProviding
	private let pageSize = 20

	private var currentPage = 0
	private var isLastPage = false

	init(
		fetchOrdersUseCase: FetchPharmacyOrdersUseCaseProtocol,
		getProfileUseCase: GetPharmacyProfileUseCaseProtocol,
		appSettings: PharmacyAppSettings,
		identityProvider: PharmacyIdentityProviding
	) {
		self.fetchOrdersUseCase = fetchOrdersUseCase
		self.getProfileUseCase = getProfileUseCase
		self.appSettings = appSettings
		self.identityProvider = identityProvider
	}

	var visibleOrders: [PharmacyOrderListItem] {
		orders.filter { matchesSelectedFilter($0) && matchesSearchText($0) }
	}

	var allOrdersCount: Int {
		orders.count
	}

	var newOrdersCount: Int {
		orders.filter { $0.status == .new }.count
	}

	var pendingApprovalOrdersCount: Int {
		orders.filter { $0.status == .pendingApproval }.count
	}

	var expiredOrdersCount: Int {
		orders.filter { $0.status == .expired }.count
	}

	var completedOrdersCount: Int {
		orders.filter { $0.status == .completed }.count
	}
	func loadInitial() async {
		guard loadState != .loading else { return }
		loadState = .loading
		currentPage = 0
		isLastPage = false

		do {
			let pharmacyId = try await resolvePharmacyId()
			let page = try await fetchOrdersUseCase.execute(pharmacyId: pharmacyId, page: currentPage, size: pageSize)
			originalOrders = page.orders
			orders = page.orders.map(PharmacyOrderMapper.mapToListItem)
			isLastPage = page.isLastPage
			loadState = .loaded
		} catch let error as PharmacyOrdersResolutionError {
			loadState = .failed(error.errorDescription ?? "Something went wrong.")
		} catch {
			loadState = .failed((error as? NetworkError)?.errorDescription ?? "Something went wrong.")
		}

	}

	func refresh() async {
		await loadInitial()
	}

	func loadNextPageIfNeeded(currentItem: PharmacyOrderListItem) async {
		guard currentItem.id == visibleOrders.last?.id,
			  !isLastPage,
			  !isLoadingNextPage,
			  loadState == .loaded,
			  let pharmacyId = identityProvider.currentPharmacyId else { return }

		isLoadingNextPage = true
		defer { isLoadingNextPage = false }

		let nextPage = currentPage + 1
		do {
			let page = try await fetchOrdersUseCase.execute(pharmacyId: pharmacyId, page: nextPage, size: pageSize)
			originalOrders.append(contentsOf: page.orders)
			orders.append(contentsOf: page.orders.map(PharmacyOrderMapper.mapToListItem))
			currentPage = nextPage
			isLastPage = page.isLastPage
		} catch {

		}
	}

	func originalOrder(for id: String) -> PharmacyOrder? {
		originalOrders.first(where: { String($0.id) == id })
	}

	func clearSearch() {
		searchText = ""
	}

	func handleAction(for order: PharmacyOrderListItem) {
	}


	private func resolvePharmacyId() async throws -> Int {
		if let cached = identityProvider.currentPharmacyId {
			return cached
		}
		let profile = try await getProfileUseCase.execute()
		guard let pharmacyId = profile.pharmacyId else {
			throw PharmacyOrdersResolutionError.noPharmacy
		}
		identityProvider.currentPharmacyId = pharmacyId
		return pharmacyId
	}

	private func matchesSelectedFilter(_ order: PharmacyOrderListItem) -> Bool {
		switch selectedFilter {
			case .all: true
			case .new: order.status == .new
			case .pendingApproval: order.status == .pendingApproval
			case .expired: order.status == .expired
			case .completed: order.status == .completed
		}
	}

	private func matchesSearchText(_ order: PharmacyOrderListItem) -> Bool {
		let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !query.isEmpty else { return true }
		return order.id.localizedCaseInsensitiveContains(query)
		|| order.customerName.localizedCaseInsensitiveContains(query)
		|| order.phoneNumber.localizedCaseInsensitiveContains(query)
	}
}
