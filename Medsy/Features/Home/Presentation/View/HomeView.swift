//  HomeView.swift
//  Medsy
//
//  Created by Antoneos Philip on 14/07/2026.
//

import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    let onSearchTap: () -> Void
    let onMedicineAnalyze: () -> Void
    let onPrescription: () -> Void
    var onCompareOffers: (() -> Void)? = nil
    var onOpenOfferResult: ((OfferResult, Int) -> Void)? = nil
    let homeAddress: String
    let onAddressTap: () -> Void


    var body: some View {
        @Bindable var vm = viewModel

        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                HomeHeaderView(
                    homeAddress: homeAddress,
                    onAddressTap: onAddressTap
                )
                HomeSearchBar(onTap: onSearchTap)
                //HomeStatusSelectorView(selectedStatus: $vm.selectedStatus)
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
                        requestId: viewModel.activeRequestIds.first ?? 0
                    )
                case .firstOffer:
                    HomeFirstOfferStatusView(
                        selectedStatus: $vm.selectedStatus,
                        offerTotalPrice: viewModel.offerTotalPrice,
                        offerAvailableMedsCount: viewModel.offerAvailableMedsCount,
                        offerTotalMedsCount: viewModel.offerTotalMedsCount,
                        requestId: viewModel.firstAvailableRequestId ?? 0,
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
                        requestId: viewModel.firstAvailableRequestId ?? 0,
                        onCompareOffers: {
                            if let result = viewModel.firstAvailableOfferResult, let reqId = viewModel.firstAvailableRequestId {
                                onOpenOfferResult?(result, reqId)
                            } else {
                                onCompareOffers?()
                            }
                        }
                    )
                case .expired:
                    HomeExpiredStatusView(selectedStatus: $vm.selectedStatus)
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
        .onDisappear {
            viewModel.stopPolling()
        }
    }
}

