//
//  PrescriptionComponents.swift
//  Medsy
//
//  Created by Ahmed Elkady on 16/07/2026.
//

import SwiftUI

struct PrescriptionOptionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: MedsySpacing.md) {
                Image(systemName: icon).font(.title2).foregroundStyle(AppColor.green).frame(width: 52, height: 52).background(AppColor.lightGreen, in: Circle())
                VStack(alignment: .leading, spacing: MedsySpacing.xxs) { Text(title).font(.headline).foregroundStyle(AppColor.textPrim); Text(subtitle).font(.footnote).foregroundStyle(AppColor.textSec).multilineTextAlignment(.leading) }
                Spacer(); Image(systemName: "chevron.forward").font(.footnote.weight(.semibold)).foregroundStyle(AppColor.textSec)
            }.padding().background(AppColor.card, in: RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous)).overlay(RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous).stroke(AppColor.border))
        }.buttonStyle(.plain)
    }
}

struct PrescriptionMedicineRow: View {
    let medicine: PrescriptionMedicineDisplay
    let onConfirm: () -> Void
    let onChooseAlternative: () -> Void

    private var showsWarning: Bool {
        medicine.needsReview && !medicine.isConfirmed
    }

    var body: some View {
        VStack(alignment: .leading, spacing: MedsySpacing.sm) {
            HStack(spacing: MedsySpacing.sm) {
                Image(systemName: showsWarning ? "exclamationmark.triangle.fill" : "pills.fill")
                    .foregroundStyle(showsWarning ? AppColor.warningYellow : AppColor.green)
                    .frame(width: 40, height: 40)
                    .background(showsWarning ? Color(hex: "#FEF3C7") : AppColor.lightGreen, in: Circle())

                VStack(alignment: .leading, spacing: 3) {
                    Text(medicine.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppColor.textPrim)
                    Text(medicine.details)
                        .font(.caption)
                        .foregroundStyle(AppColor.textSec)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 3) {
                    Text(medicine.price)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(AppColor.textPrim)

                    if medicine.isConfirmed {
                        Label("prescription.review.confirmed".localized, systemImage: "checkmark.circle.fill")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(AppColor.successGreen)
                    } else if medicine.needsReview {
                        Text("prescription.needsReview".localized)
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(AppColor.warningYellow)
                    }
                }
            }

            if !medicine.isConfirmed {
                HStack(spacing: MedsySpacing.sm) {
                    Button("prescription.review.chooseAnother".localized, action: onChooseAlternative)
                        .buttonStyle(.bordered)
                        .tint(AppColor.green)

                    Button("prescription.review.confirm".localized, action: onConfirm)
                        .buttonStyle(.borderedProminent)
                        .tint(AppColor.green)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .padding()
        .background(AppColor.card, in: RoundedRectangle(cornerRadius: MedsyRadius.md, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: MedsyRadius.md, style: .continuous).stroke(AppColor.border))
    }
}

struct PrescriptionEmptyState: View {
    let icon: String
    let title: String
    let message: String
    let primaryTitle: String
    let primaryAction: () -> Void
    var isPrimaryDisabled = false
    let secondaryTitle: String
    let secondaryAction: () -> Void

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: MedsySpacing.lg) {
                    Image(systemName: icon)
                        .font(.system(size: 42, weight: .semibold))
                        .foregroundStyle(AppColor.green)
                        .frame(width: 96, height: 96)
                        .background(AppColor.lightGreen, in: Circle())

                    VStack(spacing: MedsySpacing.xs) {
                        Text(title)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(AppColor.textPrim)
                        Text(message)
                            .font(.body)
                            .foregroundStyle(AppColor.textSec)
                            .multilineTextAlignment(.center)
                    }

                    VStack(spacing: MedsySpacing.sm) {
                        PrimaryButton(
                            title: primaryTitle,
                            isDisabled: isPrimaryDisabled,
                            action: primaryAction
                        )
                        Button(secondaryTitle, action: secondaryAction)
                            .font(.body.weight(.semibold))
                            .foregroundStyle(AppColor.green)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: proxy.size.height)
                .padding(.horizontal, MedsySpacing.xl)
                .padding(.vertical, MedsySpacing.lg)
            }
        }
    }
}
