//
//  PharmacyHomeViewModel.swift
//  Medsy-Pharmacy
//

import Foundation
import Observation

@MainActor
@Observable
final class PharmacyHomeViewModel {
    enum ProfileState: Equatable {
        case idle
        case loading
        case loaded
        case failed(String)
    }

    enum OrdersState: Equatable {
        case idle
        case loading
        case loaded
        case empty
        case failed(String)
    }

    private(set) var profileState: ProfileState = .idle
    private(set) var ordersState: OrdersState = .idle
    private(set) var recentOrders: [PharmacyHomeOrder] = []

    private let getProfileUseCase: GetPharmacyProfileUseCaseProtocol
    private let fetchOrdersUseCase: FetchPharmacyOrdersUseCaseProtocol
    private let identityProvider: PharmacyIdentityProviding
    private let sessionSettings: PharmacySessionSettings
    private let pageSize = 4

    init(
        getProfileUseCase: GetPharmacyProfileUseCaseProtocol,
        fetchOrdersUseCase: FetchPharmacyOrdersUseCaseProtocol,
        identityProvider: PharmacyIdentityProviding,
        sessionSettings: PharmacySessionSettings
    ) {
        self.getProfileUseCase = getProfileUseCase
        self.fetchOrdersUseCase = fetchOrdersUseCase
        self.identityProvider = identityProvider
        self.sessionSettings = sessionSettings
    }

    func loadIfNeeded() async {
        guard profileState == .idle, ordersState == .idle else { return }
        await refresh()
    }

    func refresh() async {
        await loadProfile()
        await loadOrders()
    }

    func retryProfile() async {
        await loadProfile()
    }

    func retryOrders() async {
        await loadOrders()
    }

    private func loadProfile() async {
        profileState = .loading
        do {
            let profile = try await getProfileUseCase.execute()
            sessionSettings.updatePharmacy(
                id: profile.pharmacyId,
                name: profile.pharmacyName,
                address: profile.pharmacyAddress
            )
            profileState = .loaded
        } catch {
            profileState = .failed("pharmacy.home.profile_load_error".localized)
        }
    }

    private func loadOrders() async {
        ordersState = .loading
        do {
            guard let pharmacyId = identityProvider.currentPharmacyId else {
                throw PharmacyOrdersResolutionError.noPharmacy
            }
            let page = try await fetchOrdersUseCase.execute(
                pharmacyId: pharmacyId,
                page: 0,
                size: pageSize
            )
            recentOrders = page.orders.prefix(pageSize).map { order in
                PharmacyHomeOrder(order: order)
            }
            ordersState = recentOrders.isEmpty ? .empty : .loaded
        } catch {
            ordersState = .failed("pharmacy.home.orders_load_error".localized)
        }
    }
}
