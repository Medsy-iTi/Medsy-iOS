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
    case offerResult(OfferResult, Int)
    // OLD:
    // case orderReview(OfferDetailPresentationModel)
    case orderReview(OfferDetailPresentationModel, Int? = nil)
    case orderComplete(ConfirmOfferResult, OfferDetailPresentationModel)
    case medicineAnalyze
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

    func openOfferResult(_ result: OfferResult, requestId: Int) {
        path.append(HomeRoute.offerResult(result, requestId))
    }

    // OLD:
    // func openOrderReview(_ offerDetail: OfferDetailPresentationModel) {
    //     path.append(HomeRoute.orderReview(offerDetail))
    // }

    func openOrderReview(_ offerDetail: OfferDetailPresentationModel, requestId: Int? = nil) {
        path.append(HomeRoute.orderReview(offerDetail, requestId))
    }

    func openOrderComplete(_ result: ConfirmOfferResult, offerDetail: OfferDetailPresentationModel) {
        path.append(HomeRoute.orderComplete(result, offerDetail))
    }

    func showMedicineAnalyze() {
        path.append(HomeRoute.medicineAnalyze)
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
    private let onOpenCart: () -> Void

    init(
        requestedRoute: Binding<HomeRoute?> = .constant(nil),
        onTabBarHiddenChange: @escaping (Bool) -> Void = { _ in },
        onOpenCart: @escaping () -> Void = {}
    ) {
        _requestedRoute = requestedRoute
        self.onTabBarHiddenChange = onTabBarHiddenChange
        self.onOpenCart = onOpenCart
    }

    var body: some View {
        @Bindable var coordinator = coordinator

        NavigationStack(path: $coordinator.path) {
            HomeView(
                onSearchTap: coordinator.openSearch,
                onMedicineAnalyze: coordinator.showMedicineAnalyze,
                onPrescription: coordinator.showPrescription,
                onCompareOffers: coordinator.openOffersList,
                onOpenOfferResult: coordinator.openOfferResult
            )
            .navigationDestination(for: HomeRoute.self) { route in
                switch route {
                case let .search(query):
                    SearchCoordinatorView(query: query, onBack: coordinator.goBack, onPush: { dest in
                        coordinator.path.append(dest)
                    })
                case .prescription:
                    PrescriptionCoordinatorView(
                        onExit: coordinator.goBack,
                        onViewCart: {
                            coordinator.goBack()
                            onOpenCart()
                        }
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
                        onSelectOffer: { updatedDetail in
                            coordinator.openOrderReview(updatedDetail)
                        }
                    )
                case let .offerResult(result, requestId):
                    OfferDetailsView(
                        offerResult: result,
                        requestId: requestId,
                        onBack: coordinator.goBack,
                        onPrescriptionTap: coordinator.showPrescription,
                        onSelectOffer: { updatedDetail in
                            coordinator.openOrderReview(updatedDetail, requestId: requestId)
                        }
                    )
                case let .orderReview(offerDetail, requestId):
                    OrderReviewView(
                        offerDetail: offerDetail,
                        requestId: requestId,
                        onBack: coordinator.goBack,
                        onConfirmOrder: { result in
                            coordinator.openOrderComplete(result, offerDetail: offerDetail)
                        }
                    )
                case let .orderComplete(result, offerDetail):
                    OrderCompleteView(
                        result: result,
                        offerDetail: offerDetail,
                        onBackToHome: {
                            coordinator.path = NavigationPath()
                        }
                    )
                case .medicineAnalyze:
                    MedicineAnalyzeView(
                        onBack: coordinator.goBack,
                        onProductSelected: { productID in
                            coordinator.path.append(
                                ProductDetailDestination(productId: productID)
                            )
                        }
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



