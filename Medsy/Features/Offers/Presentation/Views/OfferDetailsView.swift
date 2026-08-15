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
    // OLD:
    // var onSelectOffer: (() -> Void)? = nil
    var onSelectOffer: ((OfferDetailPresentationModel, SelectPharmacyResponseDTO) -> Void)? = nil
    @State private var hasRedirected = false

    init(
        offer: OfferPresentationModel? = nil,
        offerResult: OfferResult? = nil,
        requestId: Int? = nil,
        onBack: @escaping () -> Void,
        onPrescriptionTap: (() -> Void)? = nil,
        onSelectOffer: ((OfferDetailPresentationModel, SelectPharmacyResponseDTO) -> Void)? = nil
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
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    if let errorMessage = viewModel.confirmErrorMessage {
                        Text(errorMessage)
                            .font(AppColor.sans(12))
                            .foregroundStyle(AppColor.danger)
                            .padding(.horizontal, 16)
                    }

                    OfferMedicinesCardView(
                        medicines: viewModel.offerDetail.medicines,
                        onToggleSelection: { id in
                            viewModel.toggleItemSelection(id: id)
                        }
                    )

                    PharmacistCommentCardView(comment: viewModel.offerDetail.pharmacistComment)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }

            VStack(spacing: 0) {
                Button {
                    Task {
                        if let selectResult = await viewModel.selectOffer() {
                            onSelectOffer?(viewModel.offerDetail, selectResult)
                        }
                    }
                } label: {
                    HStack {
                        if viewModel.isConfirming {
                            ProgressView()
                                .tint(.white)
                        } else {
                            // OLD:
                            // Text("offers.details.selectOffer".localized)

                            Text("متابعة الطلب")
                                .font(AppColor.sans(16, .bold))
                                .foregroundStyle(AppColor.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill((viewModel.isConfirming || viewModel.isConfirmed || !viewModel.hasSelectedMedicines) ? AppColor.green.opacity(0.5) : AppColor.green)
                    )
                }
                .disabled(viewModel.isConfirming || viewModel.isConfirmed || !viewModel.hasSelectedMedicines)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(AppColor.bg)
        }
        .environment(\.layoutDirection, languageManager.isRTL ? .rightToLeft : .leftToRight)
        .background(AppColor.bg.ignoresSafeArea())
        .navigationTitle("offers.details.title".localized)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if !hasRedirected, let reqId = viewModel.requestId {
                if let savedData = UserDefaults.standard.data(forKey: "request.selectResult.\(reqId)"),
                   let selectResult = try? JSONDecoder().decode(SelectPharmacyResponseDTO.self, from: savedData) {
                    hasRedirected = true
                    onSelectOffer?(viewModel.offerDetail, selectResult)
                }
            }
        }
    }
}
