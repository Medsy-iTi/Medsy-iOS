//
//  PrescriptionReviewView.swift
//  Medsy
//
//  Created by Ehab Salah on 22/07/2026.
//

import SwiftUI

// MARK: - View

struct PrescriptionReviewView: View {
    let imageData: Data?
    let medicines: [PrescriptionMedicineDisplay]
    let confirmedCount: Int
    let needsReviewCount: Int
    let canAddToCart: Bool
    let isAddingToCart: Bool
    let cartErrorMessage: String?
    let expandedMedicineID: String?
    let onToggleCandidates: (String) -> Void
    let onSelectCandidate: (String, Int) -> Void
    let onSearchCatalog: (String) -> Void
    let onIncreaseQuantity: (String) -> Void
    let onDecreaseQuantity: (String) -> Void
    let onDelete: (String) -> Void
    let onAddToCart: () -> Void
    let onBack: () -> Void

    var body: some View {
        PrescriptionPage(title: "prescription.review.title".localized, onBack: onBack) {
            VStack(spacing: 0) {
                ScrollView {
                    LazyVStack(spacing: MedsySpacing.md) {
                        VStack(alignment: .leading, spacing: MedsySpacing.sm) {
                            Text("prescription.review.message".localized)
                                .font(MedsyFont.body(13))
                                .foregroundStyle(AppColor.textSec)

                            PrescriptionReviewSummaryCard(
                                imageData: imageData,
                                totalCount: medicines.count,
                                recognizedCount: confirmedCount,
                                needsReviewCount: needsReviewCount
                            )
                        }

                        ForEach(medicines) { medicine in
                            PrescriptionMedicineRow(
                                medicine: medicine,
                                isExpanded: expandedMedicineID == medicine.id,
                                onToggleCandidates: { onToggleCandidates(medicine.id) },
                                onSelectCandidate: { onSelectCandidate(medicine.id, $0) },
                                onSearchCatalog: { onSearchCatalog(medicine.id) },
                                onIncreaseQuantity: { onIncreaseQuantity(medicine.id) },
                                onDecreaseQuantity: { onDecreaseQuantity(medicine.id) },
                                onDelete: { onDelete(medicine.id) }
                            )
                        }

                        if !canAddToCart {
                            PrescriptionReviewBlockingBanner()
                        }
                    }
                    .padding(.horizontal, MedsySpacing.md)
                    .padding(.top, MedsySpacing.sm)
                    .padding(.bottom, 108)
                }

                PrimaryButton(
                    title: isAddingToCart
                        ? "prescription.review.addingToCart".localized
                        : "prescription.review.addToCart".localized,
                    isDisabled: !canAddToCart,
                    action: onAddToCart
                )
                .padding(.horizontal, MedsySpacing.md)
                .padding(.top, MedsySpacing.sm)

                if let cartErrorMessage {
                    Text(cartErrorMessage)
                        .font(MedsyFont.caption(12))
                        .foregroundStyle(AppColor.danger)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, MedsySpacing.md)
                        .padding(.top, MedsySpacing.xs)
                }

                Spacer().frame(height: MedsySpacing.sm)
                    .background(.ultraThinMaterial)
            }
        }
    }
}
