import SwiftUI

struct OrderReviewView: View {
    @Environment(LanguageManager.self) private var languageManager
    @State private var viewModel: OrderReviewViewModel
    let onBack: () -> Void
    var onPharmacyTap: ((Int) -> Void)? = nil
    var onConfirmOrder: ((ConfirmOfferResult) -> Void)? = nil

    init(
        offerDetail: OfferDetailPresentationModel? = nil,
        requestId: Int? = nil,
        selectResult: SelectPharmacyResponseDTO? = nil,
        paymentMethod: String? = nil,
        onBack: @escaping () -> Void,
        onPharmacyTap: ((Int) -> Void)? = nil,
        onConfirmOrder: ((ConfirmOfferResult) -> Void)? = nil
    ) {
        _viewModel = State(initialValue: OrderReviewViewModel(
            offerDetail: offerDetail,
            requestId: requestId,
            selectResult: selectResult,
            paymentMethod: paymentMethod
        ))
        self.onBack = onBack
        self.onPharmacyTap = onPharmacyTap
        self.onConfirmOrder = onConfirmOrder
    }

    var body: some View {
        VStack(spacing: 0) {
            OrderReviewHeaderView(onBack: onBack)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    if let errorMessage = viewModel.confirmErrorMessage {
                        Text(errorMessage)
                            .font(AppColor.sans(12))
                            .foregroundStyle(AppColor.danger)
                            .padding(.horizontal, 16)
                    }

                    OrderReviewMedicinesCardView(medicines: viewModel.orderReview.medicines)

                    OrderReviewPharmacyCardView(
                        pharmacyName: viewModel.orderReview.pharmacyName,
                        managerName: viewModel.orderReview.managerName,
                        onTap: {
                            if let id = viewModel.pharmacyId {
                                onPharmacyTap?(id)
                            }
                        }
                    )

                    OrderReviewPaymentMethodCardView(paymentMethod: viewModel.paymentMethod)

                    if viewModel.selectedReceiveMethod == .delivery {
                        OrderReviewAddressCardView(address: viewModel.orderReview.deliveryAddress)
                    }

                    VStack(alignment: .trailing, spacing: 12) {
                        Text("complete_request.receive.title".localized)
                            .font(AppColor.sans(16, .bold))
                            .foregroundStyle(AppColor.textPrim)
                            .padding(.horizontal, 4)

                        Button {
                            viewModel.selectedReceiveMethod = .delivery
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "box.truck.fill")
                                    .font(.system(size: 20))
                                    .foregroundStyle(AppColor.green)
                                    .frame(width: 40, height: 40)
                                    .background(AppColor.green.opacity(0.1))
                                    .cornerRadius(8)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("complete_request.receive.delivery".localized)
                                        .font(AppColor.sans(14, .bold))
                                        .foregroundStyle(AppColor.textPrim)

                                    Text("Total: \(Int(viewModel.orderReview.medicinesSubtotal + (viewModel.selectResult?.deliveryFees ?? 0.0))) EGP")
                                        .font(AppColor.sans(12))
                                        .foregroundStyle(AppColor.textSec)
                                }

                                Spacer()

                                Image(systemName: viewModel.selectedReceiveMethod == .delivery ? "largecircle.fill.circle" : "circle")
                                    .font(.system(size: 20))
                                    .foregroundStyle(viewModel.selectedReceiveMethod == .delivery ? AppColor.green : AppColor.textSec)
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(viewModel.selectedReceiveMethod == .delivery ? AppColor.green.opacity(0.05) : AppColor.card)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(viewModel.selectedReceiveMethod == .delivery ? AppColor.green : AppColor.border, lineWidth: 1)
                                    )
                            )
                        }

                        Button {
                            viewModel.selectedReceiveMethod = .pickup
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "house.fill")
                                    .font(.system(size: 20))
                                    .foregroundStyle(AppColor.green)
                                    .frame(width: 40, height: 40)
                                    .background(AppColor.green.opacity(0.1))
                                    .cornerRadius(8)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("complete_request.receive.pickup".localized)
                                        .font(AppColor.sans(14, .bold))
                                        .foregroundStyle(AppColor.textPrim)

                                    Text("Total: \(Int(viewModel.orderReview.medicinesSubtotal)) EGP")
                                        .font(AppColor.sans(12))
                                        .foregroundStyle(AppColor.textSec)
                                }

                                Spacer()

                                Image(systemName: viewModel.selectedReceiveMethod == .pickup ? "largecircle.fill.circle" : "circle")
                                    .font(.system(size: 20))
                                    .foregroundStyle(viewModel.selectedReceiveMethod == .pickup ? AppColor.green : AppColor.textSec)
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(viewModel.selectedReceiveMethod == .pickup ? AppColor.green.opacity(0.05) : AppColor.card)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(viewModel.selectedReceiveMethod == .pickup ? AppColor.green : AppColor.border, lineWidth: 1)
                                    )
                            )
                        }
                    }

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
                    Task {
                        let success = await viewModel.confirmOrder()
                        if success, let result = viewModel.confirmOfferResult {
                            onConfirmOrder?(result)
                        }
                    }
                } label: {
                    HStack {
                        if viewModel.isConfirming {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("orderReview.confirmOrder".localized)
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
                .disabled(viewModel.isConfirming || viewModel.isConfirmed)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(AppColor.bg)
        }
        .environment(\.layoutDirection, languageManager.isRTL ? .rightToLeft : .leftToRight)
        .background(AppColor.bg.ignoresSafeArea())
        .navigationBarHidden(true)
        .task {
            await viewModel.loadRequestDetails()
        }
    }
}
