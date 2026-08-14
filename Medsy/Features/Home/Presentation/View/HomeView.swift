import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    let onSearchTap: () -> Void
    let onMedicineAnalyze: () -> Void
    let onPrescription: () -> Void
    var onCompareOffers: (() -> Void)? = nil
    var onOpenOfferResult: ((OfferResult, Int) -> Void)? = nil
    var onContinueOrder: ((MasterOrderDTO) -> Void)? = nil
    let homeAddress: String
    let onAddressTap: () -> Void


    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        @Bindable var vm = viewModel

        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                HomeHeaderView(
                    homeAddress: homeAddress,
                    onAddressTap: onAddressTap
                )
                HomeSearchBar(onTap: onSearchTap)
                HomePromoBanner()

                switch viewModel.selectedStatus {
                case .home:
                    HomeOrderOptionsView(
                        onMedicineAnalyze: onMedicineAnalyze,
                        onPrescription: onPrescription
                    )
                case .searching:
                    HomeSearchingStatusView(
                        selectedStatus: $vm.selectedStatus,
                        requestId: viewModel.activeRequestIds.first ?? 0,
                        createdAt: viewModel.activeRequestCreatedAt,
                        onTimerExpired: {
                            viewModel.checkAndStartPolling()
                        }
                    )
                case .firstOffer:
                    HomeFirstOfferStatusView(
                        selectedStatus: $vm.selectedStatus,
                        offerTotalPrice: viewModel.offerTotalPrice,
                        offerAvailableMedsCount: viewModel.offerAvailableMedsCount,
                        offerTotalMedsCount: viewModel.offerTotalMedsCount,
                        requestId: viewModel.firstAvailableRequestId ?? 0,
                        createdAt: viewModel.activeRequestCreatedAt,
                        onTimerExpired: {
                            viewModel.checkAndStartPolling()
                        },
                        onCompareOffers: {
                            if let result = viewModel.firstAvailableOfferResult, let reqId = viewModel.firstAvailableRequestId {
                                onOpenOfferResult?(result, reqId)
                            } else {
                                onCompareOffers?()
                            }
                        },
                        onDelete: {
                            if let reqId = viewModel.firstAvailableRequestId {
                                viewModel.clearCompletedRequest(requestId: reqId)
                            }
                        }
                    )
                case .multipleOffers:
                    HomeMultipleOffersStatusView(
                        selectedStatus: $vm.selectedStatus,
                        offersAvailableCount: viewModel.availableOffersCount,
                        offerTotalPrice: viewModel.offerTotalPrice,
                        offerAvailableMedsCount: viewModel.offerAvailableMedsCount,
                        offerTotalMedsCount: viewModel.offerTotalMedsCount,
                        requestId: viewModel.firstAvailableRequestId ?? 0,
                        createdAt: viewModel.activeRequestCreatedAt,
                        onTimerExpired: {
                            viewModel.checkAndStartPolling()
                        },
                        onShowOffer: {
                            if let result = viewModel.firstAvailableOfferResult, let reqId = viewModel.firstAvailableRequestId {
                                onOpenOfferResult?(result, reqId)
                            }
                        },
                        onCompareOffers: {
                            onCompareOffers?()
                        },
                        onDelete: {
                            if let reqId = viewModel.firstAvailableRequestId {
                                viewModel.clearCompletedRequest(requestId: reqId)
                            }
                        }
                    )
                case .expired:
                    HomeExpiredStatusView(selectedStatus: $vm.selectedStatus)
                case .continueOrder:
                    HomeContinueOrderStatusView(
                        onContinue: {
                            if let order = viewModel.activeContinueMasterOrder {
                                onContinueOrder?(order)
                            }
                        }
                    )
                }

                HomeCategoriesView()
                HomeQuickDeliveryBanner()
                Color.clear.frame(height: 20)
            }
        }
        .background(AppColor.bg)
        .onAppear {
            viewModel.checkAndStartPolling()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                viewModel.checkAndStartPolling()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            viewModel.checkAndStartPolling()
        }
    }
}

