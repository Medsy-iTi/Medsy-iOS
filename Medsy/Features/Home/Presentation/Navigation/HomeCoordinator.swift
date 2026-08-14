import Observation
import SwiftUI

enum HomeRoute: Hashable {
    case search(String)
    case prescription
    case offersList
    case offerDetails(OfferPresentationModel)
    case offerResult(OfferResult, Int)
    case orderReview(OfferDetailPresentationModel, Int? = nil, SelectPharmacyResponseDTO? = nil, String? = nil)
    case orderComplete(ConfirmOfferResult, OfferDetailPresentationModel)
    case medicineAnalyze
    case pharmacyProfile(Int)
}

@MainActor
@Observable
final class HomeCoordinator {
    var path = NavigationPath()

    func openPharmacyProfile(_ id: Int) {
        path.append(HomeRoute.pharmacyProfile(id))
    }

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

    func openOrderReview(_ offerDetail: OfferDetailPresentationModel, requestId: Int? = nil, selectResult: SelectPharmacyResponseDTO? = nil, paymentMethod: String? = nil) {
        path.append(HomeRoute.orderReview(offerDetail, requestId, selectResult, paymentMethod))
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

    func goToHome() {
        path = NavigationPath()
    }
}

struct HomeCoordinatorView: View {
    @State private var coordinator = HomeCoordinator()
    @Binding private var requestedRoute: HomeRoute?
    @Binding private var rootResetSignal: Int
    private let onTabBarHiddenChange: (Bool) -> Void
    private let onOpenCart: () -> Void
    private let homeAddress: String
    private let onOpenProfile: () -> Void

    init(
        requestedRoute: Binding<HomeRoute?> = .constant(nil),
        rootResetSignal: Binding<Int> = .constant(0),
        onTabBarHiddenChange: @escaping (Bool) -> Void = { _ in },
        onOpenCart: @escaping () -> Void = {},
        homeAddress: String,
        onOpenProfile: @escaping () -> Void
    ) {
        _requestedRoute = requestedRoute
        _rootResetSignal = rootResetSignal
        self.onTabBarHiddenChange = onTabBarHiddenChange
        self.onOpenCart = onOpenCart
        self.homeAddress = homeAddress
        self.onOpenProfile = onOpenProfile
    }

    var body: some View {
        @Bindable var coordinator = coordinator

        NavigationStack(path: $coordinator.path) {
            HomeView(
                onSearchTap: coordinator.openSearch,
                onMedicineAnalyze: coordinator.showMedicineAnalyze,
                onPrescription: coordinator.showPrescription,
                onCompareOffers: coordinator.openOffersList,
                onOpenOfferResult: coordinator.openOfferResult,
                onContinueOrder: { order in
                    coordinator.openOrderReview(order.toOfferDetail(), requestId: order.requestId, selectResult: order.toSelectResult())
                },
                homeAddress: homeAddress,
                onAddressTap: onOpenProfile
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
                        onSelectOffer: { updatedDetail, selectResult in
                            coordinator.openOrderReview(updatedDetail, selectResult: selectResult, paymentMethod: updatedDetail.paymentMethod)
                        }
                    )
                case let .offerResult(result, requestId):
                    OfferDetailsView(
                        offerResult: result,
                        requestId: requestId,
                        onBack: coordinator.goBack,
                        onPrescriptionTap: coordinator.showPrescription,
                        onSelectOffer: { updatedDetail, selectResult in
                            coordinator.openOrderReview(updatedDetail, requestId: requestId, selectResult: selectResult, paymentMethod: result.paymentMethod ?? updatedDetail.paymentMethod)
                        }
                    )
                case let .orderReview(offerDetail, requestId, selectResult, paymentMethod):
                    OrderReviewView(
                        offerDetail: offerDetail,
                        requestId: requestId,
                        selectResult: selectResult,
                        paymentMethod: paymentMethod,
                        onBack: coordinator.goToHome,
                        onPharmacyTap: { pharmacyId in
                            coordinator.openPharmacyProfile(pharmacyId)
                        },
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
                case let .pharmacyProfile(pharmacyId):
                    PharmacyProfileView(pharmacyId: pharmacyId)
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
        .onChange(of: rootResetSignal) { _, _ in
            coordinator.path = NavigationPath()
            onTabBarHiddenChange(false)
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

extension MasterOrderDTO {
    func toSelectResult() -> SelectPharmacyResponseDTO {
        SelectPharmacyResponseDTO(
            requestId: requestId,
            offers: orderResponses ?? [],
            deliveryFees: deliveryFee ?? 0,
            totalPrice: totalPrice ?? 0
        )
    }

    func toOfferDetail() -> OfferDetailPresentationModel {
        var items: [OfferMedicineItem] = []
        for offer in orderResponses ?? [] {
            for item in offer.items {
                let medName = item.product?.name ?? item.product?.productName ?? "Medicine"
                let medImg = item.product?.imageUrl
                let medDosage = item.product?.strength ?? item.product?.form ?? ""
                items.append(
                    OfferMedicineItem(
                        id: "\(item.id)",
                        requestItemId: item.id,
                        productId: item.productId ?? item.product?.id,
                        name: medName,
                        dosage: medDosage,
                        price: item.totalPrice > 0 ? item.totalPrice : (Double(item.quantity) * item.unitPrice),
                        isAvailable: true,
                        isAlternative: false,
                        imageName: "pill.fill",
                        imageUrl: medImg,
                        isSelected: true,
                        quantity: item.quantity,
                        supplierName: offer.pharmacyName
                    )
                )
            }
        }

        return OfferDetailPresentationModel(
            id: "\(id)",
            pharmacyName: orderResponses?.first?.pharmacyName ?? "offers.details.title".localized,
            managerName: "",
            medicines: items,
            pharmacistComment: "",
            totalPrice: totalPrice ?? 0,
            prescriptionUrl: nil,
            paymentMethod: paymentMethod
        )
    }
}


