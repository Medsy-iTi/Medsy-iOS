//  PharmacyPrescriptionCard.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 23/07/2026.
//

import SwiftUI

struct PharmacyPrescriptionCard: View {
    let imageUrl: String?
    let onEnlarge: () -> Void
    let onToggleSideBySide: () -> Void
    var isSideBySideActive: Bool = false

    var body: some View {
        VStack(alignment: .trailing, spacing: PharmacySpacing.sm) {
            HStack(spacing: 8) {
                Button(action: onToggleSideBySide) {
                    HStack(spacing: 4) {
                        Image(systemName: isSideBySideActive ? "rectangle.split.2x1.fill" : "rectangle.split.2x1")
                            .font(.system(size: 13, weight: .bold))
                        Text("pharmacy.request.compare_side_by_side".localized)
                            .font(PharmacyColor.sans(12, .semibold))
                    }
                    .foregroundStyle(PharmacyColor.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(PharmacyColor.primarySoft, in: Capsule())
                }
                .buttonStyle(.plain)

                Spacer()

                Text("pharmacy.request.prescription_image".localized)
                    .font(PharmacyColor.sans(15, .bold))
                    .foregroundStyle(PharmacyColor.textPrimary)

                Image(systemName: "doc.text.viewfinder")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(PharmacyColor.primary)
            }

            Text("pharmacy.request.prescription_subtitle".localized)
                .font(PharmacyColor.sans(12, .regular))
                .foregroundStyle(PharmacyColor.textSecondary)

            ZStack(alignment: .bottomTrailing) {
                RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous)
                    .fill(PharmacyColor.mutedSurface)
                    .frame(height: 180)

                VStack(spacing: 8) {
                    Image(systemName: "cross.case.circle.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(PharmacyColor.primary.opacity(0.8))
                    Text("صورة الروشتة بخط اليد")
                        .font(PharmacyColor.sans(13, .bold))
                        .foregroundStyle(PharmacyColor.textPrimary)
                    Text("اضغط للتكبير والتحقق من الأصناف والجرعات")
                        .font(PharmacyColor.sans(11, .regular))
                        .foregroundStyle(PharmacyColor.textSecondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                Button(action: onEnlarge) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .font(.system(size: 11, weight: .bold))
                        Text("pharmacy.request.view_full_image".localized)
                            .font(PharmacyColor.sans(11, .bold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(PharmacyColor.primary, in: Capsule())
                    .padding(8)
                }
                .buttonStyle(.plain)
            }
            .clipShape(RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous))
            .onTapGesture {
                onEnlarge()
            }
        }
        .padding(PharmacySpacing.md)
        .background(PharmacyColor.card, in: RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous)
                .stroke(PharmacyColor.border, lineWidth: 1)
        )
    }
}
