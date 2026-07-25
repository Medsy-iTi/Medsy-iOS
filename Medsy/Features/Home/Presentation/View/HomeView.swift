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

    var body: some View {
        @Bindable var vm = viewModel

        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                HomeHeaderView()
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
                    HomeSearchingStatusView(selectedStatus: $vm.selectedStatus)
                case .firstOffer:
                    HomeFirstOfferStatusView(
                        selectedStatus: $vm.selectedStatus,
                        onCompareOffers: {
                            if let result = viewModel.offerResult, let reqId = viewModel.activeRequestId {
                                onOpenOfferResult?(result, reqId)
                            } else {
                                onCompareOffers?()
                            }
                        }
                    )
                case .multipleOffers:
                    HomeMultipleOffersStatusView(
                        selectedStatus: $vm.selectedStatus,
                        onCompareOffers: {
                            if let result = viewModel.offerResult, let reqId = viewModel.activeRequestId {
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
        .task {
            viewModel.checkAndStartPolling()
        }
        .onDisappear {
            viewModel.stopPolling()
        }
    }
}

