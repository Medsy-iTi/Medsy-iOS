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
    case expired

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
        case .expired:
            "payment.status.expired.title".localized
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
        case .expired:
            "payment.status.expired.message".localized
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
        case .expired:
            "clock.badge.xmark"
        }
    }

    var tint: Color {
        switch self {
        case .processing:
            AppColor.green
        case .success:
            AppColor.successGreen
        case .failure:
            AppColor.danger
        case .cancelled:
            AppColor.textSec
        case .expired:
            AppColor.danger
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
        case .expired:
            "payment.action.view_order".localized
        }
    }

    var showsSecondaryAction: Bool {
        switch self {
        case .failure, .cancelled:
            true
        case .processing, .success, .expired:
            false
        }
    }
}

enum PaymentOrderActionPresentation: Equatable {
    case payNow
    case retry
    case processing
    case expired

    var title: String {
        switch self {
        case .payNow:
            "payment.action.pay_now".localized
        case .retry:
            "payment.action.retry".localized
        case .processing:
            "payment.action.processing".localized
        case .expired:
            "payment.action.expired".localized
        }
    }

    var isLoading: Bool {
        self == .processing
    }

    var isDisabled: Bool {
        switch self {
        case .processing, .expired:
            true
        case .payNow, .retry:
            false
        }
    }

    var systemImage: String? {
        switch self {
        case .payNow, .retry:
            "creditcard.fill"
        case .expired:
            "clock.badge.xmark"
        case .processing:
            nil
        }
    }
}
