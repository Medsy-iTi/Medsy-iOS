//
//  OrderCompleteView.swift
//  Medsy
//
//  Created by Antoneos Philip on 25/07/2026.
//

import SwiftUI

struct OrderCompleteView: View {
    @Environment(LanguageManager.self) private var languageManager
    let result: ConfirmOfferResult
    let offerDetail: OfferDetailPresentationModel
    let onBackToHome: () -> Void

    @State private var animateCheckmark = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Success checkmark animation
            ZStack {
                Circle()
                    .fill(AppColor.green.opacity(0.15))
                    .frame(width: 100, height: 100)
                    .scaleEffect(animateCheckmark ? 1.0 : 0.8)

                Circle()
                    .fill(AppColor.green)
                    .frame(width: 80, height: 80)
                    .scaleEffect(animateCheckmark ? 1.0 : 0.5)

                Image(systemName: "checkmark")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(.white)
                    .opacity(animateCheckmark ? 1.0 : 0.0)
            }
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0)) {
                    animateCheckmark = true
                }
            }

            VStack(spacing: 8) {
                Text("order_complete.thank_you".localized)
                    .font(AppColor.sans(22, .bold))
                    .foregroundStyle(AppColor.textPrim)
                    .multilineTextAlignment(.center)

                Text("order_complete.success_message".localized)
                    .font(AppColor.sans(14))
                    .foregroundStyle(AppColor.textSec)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            // Real Data summary card
            VStack(spacing: 16) {
                HStack {
                    Text("order_complete.summary_title".localized)
                        .font(AppColor.sans(14, .bold))
                        .foregroundStyle(AppColor.textSec)
                    Spacer()
                }

                Divider()

                HStack {
                    Text("order_complete.pharmacy".localized)
                        .font(AppColor.sans(14))
                        .foregroundStyle(AppColor.textSec)
                    Spacer()
                    Text(offerDetail.pharmacyName)
                        .font(AppColor.sans(14, .bold))
                        .foregroundStyle(AppColor.textPrim)
                }

                HStack {
                    Text("order_complete.medicines_count".localized)
                        .font(AppColor.sans(14))
                        .foregroundStyle(AppColor.textSec)
                    Spacer()
                    Text(String(format: "order_complete.medicines_count_value".localized, offerDetail.medicines.count))
                        .font(AppColor.sans(14, .bold))
                        .foregroundStyle(AppColor.textPrim)
                }

                if let firstOrder = result.orders.first {
                    HStack {
                        Text("order_complete.order_id".localized)
                            .font(AppColor.sans(14))
                            .foregroundStyle(AppColor.textSec)
                        Spacer()
                        Text("#\(firstOrder.orderId)")
                            .font(AppColor.sans(14, .bold))
                            .foregroundStyle(AppColor.textPrim)
                    }
                }

                Divider()

                HStack {
                    Text("order_complete.total".localized)
                        .font(AppColor.sans(16, .bold))
                        .foregroundStyle(AppColor.textPrim)
                    Spacer()
                    Text(String(format: "%.2f %@", offerDetail.totalPrice, "common.egp".localized))
                        .font(AppColor.sans(18, .bold))
                        .foregroundStyle(AppColor.green)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(AppColor.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.gray.opacity(0.12), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 24)

            Spacer()

            Button(action: onBackToHome) {
                Text("order_complete.back_home".localized)
                    .font(AppColor.sans(16, .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(AppColor.green)
                    )
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .environment(\.layoutDirection, languageManager.isRTL ? .rightToLeft : .leftToRight)
        .background(AppColor.bg.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}
