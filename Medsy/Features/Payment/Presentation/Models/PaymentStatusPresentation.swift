//
//  PaymentStatusPresentation.swift
//  Medsy
//
//  Created by Ahmed Elkady on 02/08/2026.
//

import SwiftUI

enum PaymentStatusPresentation: Equatable {
    case processing
    case success
    case failure(message: String?)
    case cancelled
    case unsupportedCombinedOrder

    var title: String {
        switch self {
        case .processing:
            "payment.status.processing.title".localized
        case .success:
            "payment.status.success.title".localized
        case .failure:
            "payment.status.failure.title".localized
        case .cancelled:
            "payment.status.cancelled.title".localized
        case .unsupportedCombinedOrder:
            "payment.status.unsupported.title".localized
        }
    }

    var message: String {
        switch self {
        case .processing:
            "payment.status.processing.message".localized
        case .success:
            "payment.status.success.message".localized
        case .failure(let message):
            message ?? "payment.status.failure.message".localized
        case .cancelled:
            "payment.status.cancelled.message".localized
        case .unsupportedCombinedOrder:
            "payment.status.unsupported.message".localized
        }
    }

    var systemImage: String {
        switch self {
        case .processing:
            "hourglass"
        case .success:
            "checkmark"
        case .failure:
            "exclamationmark"
        case .cancelled:
            "xmark"
        case .unsupportedCombinedOrder:
            "building.2"
        }
    }

    var tint: Color {
        switch self {
        case .processing, .unsupportedCombinedOrder:
            AppColor.green
        case .success:
            AppColor.successGreen
        case .failure:
            AppColor.danger
        case .cancelled:
            AppColor.textSec
        }
    }

    var showsProgress: Bool {
        self == .processing
    }

    var primaryActionTitle: String {
        switch self {
        case .processing:
            "payment.action.view_order".localized
        case .success:
            "payment.action.done".localized
        case .failure, .cancelled:
            "payment.action.retry".localized
        case .unsupportedCombinedOrder:
            "payment.action.back_to_offers".localized
        }
    }

    var showsSecondaryAction: Bool {
        switch self {
        case .failure, .cancelled:
            true
        case .processing, .success, .unsupportedCombinedOrder:
            false
        }
    }
}

enum PaymentOrderActionPresentation: Equatable {
    case payNow
    case retry
    case processing

    var title: String {
        switch self {
        case .payNow:
            "payment.action.pay_now".localized
        case .retry:
            "payment.action.retry".localized
        case .processing:
            "payment.action.processing".localized
        }
    }

    var isLoading: Bool {
        self == .processing
    }
}
