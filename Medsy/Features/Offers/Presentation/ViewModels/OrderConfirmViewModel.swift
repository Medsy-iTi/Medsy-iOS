//  OrderConfirmViewModel.swift
//  Medsy
//
//  Created by Antoneos Philip on 22/07/2026.

import Foundation
import Observation

@MainActor
@Observable
final class OrderConfirmViewModel {
    var orderConfirm: OrderConfirmPresentationModel

    init(orderReview: OrderReviewPresentationModel? = nil) {
        let pharmacyName = orderReview?.pharmacyName ?? "offers.list.pharmacy.nahda".localized
        let managerSuffix = "offers.details.managerSuffix".localized
        let managerName = orderReview?.managerName ?? ("محمد أحمد" + managerSuffix)

        self.orderConfirm = OrderConfirmPresentationModel(
            id: orderReview?.id ?? "1",
            orderNumber: "orderConfirm.orderNumber".localized,
            pharmacyName: pharmacyName,
            managerName: managerName,
            deliveryAddress: orderReview?.deliveryAddress ?? "orderReview.address.text".localized,
            estimatedTime: "orderConfirm.estimatedTime".localized,
            paymentMethod: "orderConfirm.paymentMethod".localized
        )
    }

    func trackOrder() {
    }
}
