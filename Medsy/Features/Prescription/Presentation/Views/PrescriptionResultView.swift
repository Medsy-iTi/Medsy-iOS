//
//  PrescriptionResultView.swift
//  Medsy
//
//  Created by Ehab Salah on 22/07/2026.
//

import SwiftUI

// MARK: - View

struct PrescriptionResultView: View {
    let result: PrescriptionFlowResult
    let primaryAction: () -> Void
    let secondaryAction: () -> Void
    let isPrimaryDisabled: Bool
    let onBack: () -> Void

    var body: some View {
        PrescriptionPage(title: "prescription.review.title".localized, onBack: onBack) {
            PrescriptionEmptyState(
                icon: content.icon,
                title: content.title,
                message: content.message,
                primaryTitle: content.primaryTitle,
                primaryAction: primaryAction,
                isPrimaryDisabled: isPrimaryDisabled,
                secondaryTitle: content.secondaryTitle,
                secondaryAction: secondaryAction
            )
        }
    }

    private var content: (icon: String, title: String, message: String, primaryTitle: String, secondaryTitle: String) {
        switch result {
        case .added:
            (
                "checkmark",
                "prescription.added.title".localized,
                "prescription.added.message".localized,
                "prescription.added.cart".localized,
                "prescription.added.home".localized
            )
        case let .analysisFailed(message):
            (
                "wifi.exclamationmark",
                "prescription.analysisFailed.title".localized,
                message,
                "prescription.retry".localized,
                "prescription.change".localized
            )
        case .noMedicines:
            (
                "pills",
                "prescription.none.title".localized,
                "prescription.none.message".localized,
                "prescription.change".localized,
                "prescription.none.manual".localized
            )
        }
    }
}
