//  OffersListView.swift
//  Medsy
//
//  Created by Antoneos Philip on 22/07/2026.

import SwiftUI

struct OffersListView: View {
    @State private var viewModel = OffersListViewModel()
    let onBack: () -> Void
    var onOfferSelected: ((OfferPresentationModel) -> Void)? = nil

    var body: some View {
        VStack(spacing: 0) {
            OffersHeaderView(
                subtitleText: viewModel.subtitleText,
                onBack: onBack
            )

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    ForEach(viewModel.offers) { offer in
                        OfferCardView(
                            offer: offer,
                            onTap: {
                                onOfferSelected?(offer)
                            }
                        )
                    }

                    Spacer().frame(height: 8)

                    OffersInfoBannerView()
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
        }
        .background(AppColor.bg.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}
