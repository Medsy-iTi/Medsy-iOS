//  OrderConfirmView.swift
//  Medsy
//
//  Created by Antoneos Philip on 22/07/2026.

import SwiftUI

struct OrderConfirmView: View {
    @Environment(LanguageManager.self) private var languageManager
    @State private var viewModel: OrderConfirmViewModel
    let onBackToHome: () -> Void
    var onTrackOrder: (() -> Void)? = nil

    init(
        orderReview: OrderReviewPresentationModel? = nil,
        onBackToHome: @escaping () -> Void,
        onTrackOrder: (() -> Void)? = nil
    ) {
        _viewModel = State(initialValue: OrderConfirmViewModel(orderReview: orderReview))
        self.onBackToHome = onBackToHome
        self.onTrackOrder = onTrackOrder
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    OrderConfirmHeaderView(orderNumber: viewModel.orderConfirm.orderNumber)

                    OrderConfirmDetailsCardView(model: viewModel.orderConfirm)

                    OrderConfirmBannerView()
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 24)
            }

            VStack(spacing: 12) {
                Button {
                    viewModel.trackOrder()
                    onTrackOrder?()
                } label: {
                    Text("orderConfirm.trackOrder".localized)
                        .font(AppColor.sans(16, .bold))
                        .foregroundStyle(AppColor.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(AppColor.green)
                        )
                }

                Button {
                    onBackToHome()
                } label: {
                    Text("orderConfirm.backToHome".localized)
                        .font(AppColor.sans(16, .bold))
                        .foregroundStyle(AppColor.textPrim)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(AppColor.card)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(AppColor.border, lineWidth: 1)
                                )
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(AppColor.bg)
        }
        .environment(\.layoutDirection, languageManager.isRTL ? .rightToLeft : .leftToRight)
        .background(AppColor.bg.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}
