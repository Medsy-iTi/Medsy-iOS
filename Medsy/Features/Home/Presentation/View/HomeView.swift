//  HomeView.swift
//  Medsy
//
//  Created by Antoneos Philip on 14/07/2026.
//

import SwiftUI

struct HomeView: View {
    @State private var selectedStatus: HomeSearchStatus = .firstOffer
    let onSearchTap: () -> Void
    let onMedicineAnalyze: () -> Void
    let onPrescription: () -> Void
    var onCompareOffers: (() -> Void)? = nil
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                HomeHeaderView()
                HomeSearchBar(onTap: onSearchTap)
                //HomeStatusSelectorView(selectedStatus: $selectedStatus)
                HomePromoBanner()
                
                switch selectedStatus {
                case .home:
                    HomeOrderOptionsView(
                        onMedicineAnalyze: onMedicineAnalyze,
                        onPrescription: onPrescription
                    )
                case .searching:
                    HomeSearchingStatusView(selectedStatus: $selectedStatus)
                case .firstOffer:
                    HomeFirstOfferStatusView(selectedStatus: $selectedStatus, onCompareOffers: onCompareOffers)
                case .multipleOffers:
                    HomeMultipleOffersStatusView(selectedStatus: $selectedStatus, onCompareOffers: onCompareOffers)
                case .expired:
                    HomeExpiredStatusView(selectedStatus: $selectedStatus)
                }
                
                HomeCategoriesView()
                HomeQuickDeliveryBanner()
                Color.clear.frame(height: 20)
            }
        }
        .background(AppColor.bg)
    }
}
