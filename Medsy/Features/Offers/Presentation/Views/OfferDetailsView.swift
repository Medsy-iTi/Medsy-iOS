//  OfferDetailsView.swift
//  Medsy
//
//  Created by Antoneos Philip on 22/07/2026.

import SwiftUI

struct OfferDetailsView: View {
    @Environment(LanguageManager.self) private var languageManager
    @State private var viewModel: OfferDetailsViewModel
    let onBack: () -> Void
    var onPrescriptionTap: (() -> Void)? = nil
    var onSelectOffer: (() -> Void)? = nil

    init(
        offer: OfferPresentationModel? = nil,
        offerResult: OfferResult? = nil,
        requestId: Int? = nil,
        onBack: @escaping () -> Void,
        onPrescriptionTap: (() -> Void)? = nil,
        onSelectOffer: (() -> Void)? = nil
    ) {
        _viewModel = State(
            initialValue: OfferDetailsViewModel(
                offer: offer,
                offerResult: offerResult,
                requestId: requestId
            )
        )
        self.onBack = onBack
        self.onPrescriptionTap = onPrescriptionTap
        self.onSelectOffer = onSelectOffer
    }

    var body: some View {
        VStack(spacing: 0) {
            OfferDetailsHeaderView(
                pharmacyName: viewModel.offerDetail.pharmacyName,
                managerName: viewModel.offerDetail.managerName,
                onBack: onBack
            )

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    if let errorMessage = viewModel.confirmErrorMessage {
                        Text(errorMessage)
                            .font(AppColor.sans(12))
                            .foregroundStyle(AppColor.danger)
                            .padding(.horizontal, 16)
                    }

                    OfferMedicinesCardView(medicines: viewModel.offerDetail.medicines)

                    PharmacistCommentCardView(comment: viewModel.offerDetail.pharmacistComment)

                    PrescriptionButtonView(onTap: {
                        onPrescriptionTap?()
                    })
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }

            VStack(spacing: 0) {
                Button {
                    Task {
                        let success = await viewModel.selectOffer()
                        if success {
                            onSelectOffer?()
                        }
                    }
                } label: {
                    HStack {
                        if viewModel.isConfirming {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("offers.details.selectOffer".localized)
                                .font(AppColor.sans(16, .bold))
                                .foregroundStyle(AppColor.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(AppColor.green)
                    )
                }
                .disabled(viewModel.isConfirming)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(AppColor.bg)
        }
        .environment(\.layoutDirection, languageManager.isRTL ? .rightToLeft : .leftToRight)
        .background(AppColor.bg.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}
