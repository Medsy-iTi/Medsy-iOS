//
//  HomeCoordinator.swift
//  Medsy
//
//  Created by Ehab Salah on 16/07/2026.
//

import Observation
import SwiftUI

enum HomeRoute: Hashable {
    case search(String)
    case prescription
    case offersList
    case offerDetails(OfferPresentationModel)
    case orderReview(OfferDetailPresentationModel)
}

@MainActor
@Observable
final class HomeCoordinator {
    var path = NavigationPath()

    func openSearch() {
        path.append(HomeRoute.search(""))
    }

    func showPrescription() {
        path.append(HomeRoute.prescription)
    }

    func openOffersList() {
        path.append(HomeRoute.offersList)
    }

    func openOfferDetails(_ offer: OfferPresentationModel) {
        path.append(HomeRoute.offerDetails(offer))
    }

    func openOrderReview(_ offerDetail: OfferDetailPresentationModel) {
        path.append(HomeRoute.orderReview(offerDetail))
    }

    func open(_ route: HomeRoute) {
        path.append(route)
    }

    func goBack() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
}

struct HomeCoordinatorView: View {
    @State private var coordinator = HomeCoordinator()
    @Binding private var requestedRoute: HomeRoute?
    private let onTabBarHiddenChange: (Bool) -> Void

    init(
        requestedRoute: Binding<HomeRoute?> = .constant(nil),
        onTabBarHiddenChange: @escaping (Bool) -> Void = { _ in }
    ) {
        _requestedRoute = requestedRoute
        self.onTabBarHiddenChange = onTabBarHiddenChange
    }

    var body: some View {
        @Bindable var coordinator = coordinator

        NavigationStack(path: $coordinator.path) {
            HomeView(
                onSearchTap: coordinator.openSearch,
                onPrescription: coordinator.showPrescription,
                onCompareOffers: coordinator.openOffersList
            )
            .navigationDestination(for: HomeRoute.self) { route in
                switch route {
                case let .search(query):
                    SearchCoordinatorView(query: query, onBack: coordinator.goBack, onPush: { dest in
                        coordinator.path.append(dest)
                    })
                case .prescription:
                    PrescriptionCoordinatorView(
                        onExit: coordinator.goBack
                    )
                case .offersList:
                    OffersListView(
                        onBack: coordinator.goBack,
                        onOfferSelected: coordinator.openOfferDetails
                    )
                case let .offerDetails(offer):
                    OfferDetailsView(
                        offer: offer,
                        onBack: coordinator.goBack,
                        onPrescriptionTap: coordinator.showPrescription,
                        onSelectOffer: {
                            coordinator.openOrderReview(
                                OfferDetailsViewModel(offer: offer).offerDetail
                            )
                        }
                    )
                case let .orderReview(offerDetail):
                    OrderReviewView(
                        offerDetail: offerDetail,
                        onBack: coordinator.goBack
                    )
                }
            }
                .navigationDestination(for: ProductDetailDestination.self) { destination in
                    ProductDetailView(productId: destination.productId)
                }
        }
        .onAppear {
            openRequestedRoute()
            onTabBarHiddenChange(!coordinator.path.isEmpty)
        }
        .onChange(of: requestedRoute) { _, _ in
            openRequestedRoute()
        }
        .onChange(of: coordinator.path.isEmpty) { _, isEmpty in
            onTabBarHiddenChange(!isEmpty)
        }
    }

    private func openRequestedRoute() {
        guard let requestedRoute else { return }
        coordinator.open(requestedRoute)
        self.requestedRoute = nil
    }
}
