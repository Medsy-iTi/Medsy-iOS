//
//  OrderDetailViewModel.swift
//  Medsy
//
//  Created by Ahmed Elkady on 21/07/2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class OrderDetailViewModel: OrderDetailViewModelProtocol {

    private(set) var detailState: OrderDetailViewState = .loading
    private(set) var reorderState: ReorderState = .idle
    private(set) var selectedPharmacyID: Int?
    private(set) var currentLocation: OrderCoordinatePresentation?
    private(set) var routeState: OrderRoutePresentationState = .idle

    private let getOrderDetailUseCase: GetOrderDetailUseCaseProtocol?
    private let reorderUseCase: ReorderUseCaseProtocol?
    private let locationProvider: OrderCurrentLocationProviding?
    private let routeProvider: OrderRouteProviding?
    private let directionsOpener: OrderDirectionsOpening?
    private var loadTask: Task<Void, Never>?
    private var reorderTask: Task<Void, Never>?
    private var routeTask: Task<Void, Never>?

    init(
        getOrderDetailUseCase: GetOrderDetailUseCaseProtocol? = nil,
        reorderUseCase: ReorderUseCaseProtocol? = nil,
        locationProvider: OrderCurrentLocationProviding? = nil,
        routeProvider: OrderRouteProviding? = nil,
        directionsOpener: OrderDirectionsOpening? = nil
    ) {
        self.getOrderDetailUseCase = getOrderDetailUseCase
        self.reorderUseCase = reorderUseCase
        self.locationProvider = locationProvider
        self.routeProvider = routeProvider
        self.directionsOpener = directionsOpener
    }

    init(
        state: OrderDetailViewState,
        reorderState: ReorderState = .idle,
        locationProvider: OrderCurrentLocationProviding? = nil,
        routeProvider: OrderRouteProviding? = nil,
        directionsOpener: OrderDirectionsOpening? = nil
    ) {
        detailState = state
        self.reorderState = reorderState
        getOrderDetailUseCase = nil
        reorderUseCase = nil
        self.locationProvider = locationProvider
        self.routeProvider = routeProvider
        self.directionsOpener = directionsOpener

        if case .loaded(let order) = state {
            prepareRoute(for: order)
        }
    }



    func handle(_ event: OrderDetailEvent) {
        switch event {
        case .load(let orderId):
            loadDetail(orderId: orderId)
        case .retry(let orderId):
            loadDetail(orderId: orderId)
        case .reorder:
            handleReorder()
        case .selectPharmacy(let pharmacyID):
            selectPharmacy(id: pharmacyID)
        case .openDirections:
            openDirections()
        case .dismissReorderFeedback:
            reorderState = .idle
        }
    }

    private func loadDetail(orderId: Int) {
        loadTask?.cancel()
        routeTask?.cancel()
        detailState = .loading
        reorderState = .idle
        selectedPharmacyID = nil
        currentLocation = nil
        routeState = .idle
        loadTask = Task {
            guard let useCase = getOrderDetailUseCase else { return }
            do {
                let entity = try await useCase.execute(id: orderId)
                guard !Task.isCancelled else { return }
                let order = OrderEntityMapper.mapDetail(entity)
                detailState = .loaded(order)
                prepareRoute(for: order)
            } catch {
                guard !Task.isCancelled else { return }
                detailState = .error(error.localizedDescription)
            }
        }
    }

    private func prepareRoute(for order: OrderDetailPresentationModel) {
        guard let pharmacy = order.pharmacies.first(where: { $0.coordinate != nil }) else {
            selectedPharmacyID = nil
            routeState = .idle
            return
        }

        selectedPharmacyID = pharmacy.id
        requestRoute(to: pharmacy)
    }

    private func selectPharmacy(id: Int) {
        guard case .loaded(let order) = detailState,
              let pharmacy = order.pharmacies.first(where: { $0.id == id && $0.coordinate != nil }) else {
            return
        }

        selectedPharmacyID = id
        requestRoute(to: pharmacy)
    }

    private func requestRoute(to pharmacy: OrderPharmacyPresentationModel) {
        routeTask?.cancel()
        guard let destination = pharmacy.coordinate,
              let locationProvider,
              let routeProvider else {
            routeState = .routeUnavailable
            return
        }

        routeTask = Task {
            do {
                let source: OrderCoordinatePresentation
                if let currentLocation {
                    source = currentLocation
                } else {
                    routeState = .locating
                    source = try await locationProvider.currentLocation()
                    guard !Task.isCancelled else { return }
                    currentLocation = source
                }

                routeState = .routing
                let points = try await routeProvider.route(from: source, to: destination)
                guard !Task.isCancelled else { return }
                routeState = points.isEmpty ? .routeUnavailable : .ready(points: points)
            } catch OrderLocationError.permissionDenied {
                guard !Task.isCancelled else { return }
                routeState = .permissionDenied
            } catch OrderLocationError.locationUnavailable {
                guard !Task.isCancelled else { return }
                routeState = .locationUnavailable
            } catch OrderLocationError.routeUnavailable {
                guard !Task.isCancelled else { return }
                routeState = .routeUnavailable
            } catch {
                guard !Task.isCancelled else { return }
                routeState = .routeUnavailable
            }
        }
    }

    private func openDirections() {
        guard case .loaded(let order) = detailState,
              let selectedPharmacyID,
              let pharmacy = order.pharmacies.first(where: { $0.id == selectedPharmacyID }),
              let coordinate = pharmacy.coordinate else {
            return
        }

        directionsOpener?.openDirections(to: coordinate, name: pharmacy.name)
    }

    private func handleReorder() {

        guard case .loaded(let order) = detailState, !order.items.isEmpty else { return }
        guard reorderState != .loading else { return }

        let items = order.items.compactMap { item in
            item.productId.map { ReorderItem(productId: $0, quantity: item.quantity) }
        }
        guard !items.isEmpty else { return }

        reorderTask?.cancel()
        reorderState = .loading
        reorderTask = Task {
            guard let useCase = reorderUseCase else {
                reorderState = .success
                return
            }
            let result = await useCase.execute(items: items)
            guard !Task.isCancelled else { return }
            switch result {
            case .success:
                reorderState = .success
            case .partial(let added, let total):
                reorderState = .partial(added: added, total: total)
            case .failure:
                reorderState = .failed
            }
        }
    }
}
