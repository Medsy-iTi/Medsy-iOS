//  OrderReviewView.swift
//  Medsy
//
//  Created by Antoneos Philip on 22/07/2026.

import SwiftUI

struct OrderReviewView: View {
    @Environment(LanguageManager.self) private var languageManager
    @State private var viewModel: OrderReviewViewModel
    let onBack: () -> Void
    var onConfirmOrder: (() -> Void)? = nil

    init(
        offerDetail: OfferDetailPresentationModel? = nil,
        onBack: @escaping () -> Void,
        onConfirmOrder: (() -> Void)? = nil
    ) {
        _viewModel = State(initialValue: OrderReviewViewModel(offerDetail: offerDetail))
        self.onBack = onBack
        self.onConfirmOrder = onConfirmOrder
    }

    var body: some View {
        VStack(spacing: 0) {
            OrderReviewHeaderView(onBack: onBack)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    OrderReviewPharmacyCardView(
                        pharmacyName: viewModel.orderReview.pharmacyName,
                        managerName: viewModel.orderReview.managerName
                    )

                    OrderReviewMedicinesCardView(medicines: viewModel.orderReview.medicines)

                    OrderReviewAddressCardView(address: viewModel.orderReview.deliveryAddress)

                    OrderReviewDeliveryDetailsCardView(fee: viewModel.orderReview.deliveryFee)

                    OrderReviewSummaryCardView(
                        medicinesSubtotal: viewModel.orderReview.medicinesSubtotal,
                        deliveryFee: viewModel.orderReview.deliveryFee,
                        totalPrice: viewModel.orderReview.totalPrice
                    )
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }

            VStack(spacing: 0) {
                Button {
                    viewModel.confirmOrder()
                    onConfirmOrder?()
                } label: {
                    Text("orderReview.confirmOrder".localized)
                        .font(AppColor.sans(16, .bold))
                        .foregroundStyle(AppColor.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(AppColor.green)
                        )
                }
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
