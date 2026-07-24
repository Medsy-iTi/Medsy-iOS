import SwiftUI

struct PrescriptionOptionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: MedsySpacing.md) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(AppColor.green)
                    .frame(width: 52, height: 52)
                    .background(AppColor.lightGreen, in: Circle())

                VStack(alignment: .leading, spacing: MedsySpacing.xxs) {
                    Text(title).font(.headline).foregroundStyle(AppColor.textPrim)
                    Text(subtitle)
                        .font(.footnote)
                        .foregroundStyle(AppColor.textSec)
                        .multilineTextAlignment(.leading)
                }

                Spacer()
                Image(systemName: "chevron.forward")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(AppColor.textSec)
            }
            .padding()
            .background(AppColor.card, in: RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous).stroke(AppColor.border))
        }
        .buttonStyle(.plain)
    }
}

struct PrescriptionMedicineRow: View {
    let medicine: PrescriptionMedicineDisplay
    let isExpanded: Bool
    let onToggleCandidates: () -> Void
    let onSelectCandidate: (Int) -> Void
    let onSearchCatalog: () -> Void
    let onIncreaseQuantity: () -> Void
    let onDecreaseQuantity: () -> Void
    let onDelete: () -> Void

    private var showsWarning: Bool {
        !medicine.isConfirmed
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            VStack(alignment: .leading, spacing: MedsySpacing.md) {
                if showsWarning {
                    Text("prescription.review.unclearMessage".localized)
                        .font(MedsyFont.caption(12))
                        .foregroundStyle(AppColor.textSec)
                }

                selectedProductSummary

                if medicine.isConfirmed {
                    confirmedActions
                } else {
                    reviewActions
                }

                if isExpanded {
                    candidatesList
                }
            }
            .padding(MedsySpacing.md)
        }
        .background(AppColor.card, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(showsWarning ? Color(hex: "#FDE68A") : AppColor.border, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var selectedProductSummary: some View {
        HStack(alignment: .center, spacing: MedsySpacing.md) {
            PrescriptionRemoteThumbnail(
                imageURL: medicine.imageURL,
                highlighted: medicine.isConfirmed
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(medicine.name)
                    .font(MedsyFont.title(15))
                    .foregroundStyle(AppColor.textPrim)
                    .lineLimit(2)

                Text(medicine.details)
                    .font(MedsyFont.caption(12))
                    .foregroundStyle(AppColor.textSec)
                    .lineLimit(2)
            }

            Spacer(minLength: MedsySpacing.sm)

            if let price = medicine.price {
                VStack(alignment: .trailing, spacing: 3) {
                    Text(price)
                        .font(MedsyFont.price(15))
                        .foregroundStyle(AppColor.green)
                        .lineLimit(1)

                    Text("prescription.review.perPack".localized)
                        .font(MedsyFont.caption(10))
                        .foregroundStyle(AppColor.textSec)
                }
            }
        }
    }

    private var reviewActions: some View {
        Group {
            if medicine.candidates.isEmpty {
                VStack(alignment: .leading, spacing: MedsySpacing.sm) {
                    Text("prescription.review.noCandidates".localized)
                        .font(MedsyFont.caption(12))
                        .foregroundStyle(AppColor.textSec)
                    catalogButton
                }
            } else {
                Button(action: onToggleCandidates) {
                    HStack {
                        Text(isExpanded
                             ? "prescription.review.hideCandidates".localized
                             : "prescription.review.showCandidates".localized)
                        Spacer()
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    }
                    .font(MedsyFont.button(13))
                    .foregroundStyle(AppColor.green)
                    .frame(height: 44)
                    .padding(.horizontal, MedsySpacing.md)
                    .overlay(
                        RoundedRectangle(cornerRadius: MedsyRadius.md, style: .continuous)
                            .stroke(AppColor.green.opacity(0.45), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var confirmedActions: some View {
        HStack {
            PrescriptionQuantityStepper(
                quantity: medicine.quantity,
                onDecrease: onDecreaseQuantity,
                onIncrease: onIncreaseQuantity
            )

            Spacer()

            Button(action: medicine.candidates.isEmpty ? onSearchCatalog : onToggleCandidates) {
                Label("prescription.review.edit".localized, systemImage: "pencil")
                    .font(MedsyFont.button(12))
                    .foregroundStyle(AppColor.textPrim)
                    .frame(height: 36)
                    .padding(.horizontal, MedsySpacing.md)
                    .overlay(Capsule().stroke(AppColor.border, lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
    }

    private var candidatesList: some View {
        VStack(alignment: .leading, spacing: MedsySpacing.sm) {
            ForEach(medicine.candidates) { candidate in
                Button {
                    onSelectCandidate(candidate.id)
                } label: {
                    HStack(spacing: MedsySpacing.sm) {
                        PrescriptionRemoteThumbnail(
                            imageURL: candidate.imageURL,
                            highlighted: medicine.selectedProduct?.productID == Int64(candidate.id)
                        )

                        VStack(alignment: .leading, spacing: 3) {
                            Text(candidate.name)
                                .font(MedsyFont.body(13).weight(.semibold))
                                .foregroundStyle(AppColor.textPrim)
                                .multilineTextAlignment(.leading)
                                .lineLimit(2)
                            if !candidate.details.isEmpty {
                                Text(candidate.details)
                                    .font(MedsyFont.caption(11))
                                    .foregroundStyle(AppColor.textSec)
                            }
                        }

                        Spacer(minLength: MedsySpacing.xs)

                        Text(candidate.formattedPrice)
                            .font(MedsyFont.price(13))
                            .foregroundStyle(AppColor.green)
                            .lineLimit(1)

                        Image(systemName: medicine.selectedProduct?.productID == Int64(candidate.id)
                              ? "checkmark.circle.fill"
                              : "circle")
                            .foregroundStyle(AppColor.green)
                    }
                    .padding(MedsySpacing.sm)
                    .background(AppColor.bg, in: RoundedRectangle(cornerRadius: MedsyRadius.md, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: MedsyRadius.md, style: .continuous)
                            .stroke(AppColor.border, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }

            catalogButton
        }
    }

    private var catalogButton: some View {
        Button(action: onSearchCatalog) {
            Label("prescription.review.searchCatalog".localized, systemImage: "magnifyingglass")
                .font(MedsyFont.button(13))
                .frame(maxWidth: .infinity)
                .frame(height: 44)
        }
        .buttonStyle(.plain)
        .foregroundStyle(AppColor.textPrim)
        .overlay(
            RoundedRectangle(cornerRadius: MedsyRadius.md, style: .continuous)
                .stroke(AppColor.border, lineWidth: 1)
        )
    }

    private var header: some View {
        HStack(spacing: MedsySpacing.xs) {
            Image(systemName: showsWarning ? "magnifyingglass" : "checkmark")
                .font(.system(size: 10, weight: .bold))

            Text(showsWarning
                 ? "prescription.review.needsReview".localized
                 : "prescription.review.recognized".localized)
                .font(MedsyFont.caption(11).weight(.semibold))

            Spacer()

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 12, weight: .semibold))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("common.delete".localized)
        }
        .foregroundStyle(showsWarning ? AppColor.warningYellow : AppColor.green)
        .padding(.horizontal, MedsySpacing.md)
        .padding(.vertical, MedsySpacing.sm)
        .background(showsWarning ? Color(hex: "#FFFBEB") : AppColor.lightGreen.opacity(0.8))
    }
}

private struct PrescriptionRemoteThumbnail: View {
    let imageURL: String?
    let highlighted: Bool

    var body: some View {
        AsyncImage(url: imageURL.flatMap(URL.init(string:))) { phase in
            switch phase {
            case let .success(image):
                image.resizable().scaledToFit().padding(4)
            default:
                Image(systemName: "pills")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(highlighted ? AppColor.green : Color(hex: "#64748B"))
            }
        }
        .frame(width: 48, height: 48)
        .background(
            highlighted ? AppColor.lightGreen.opacity(0.65) : Color(hex: "#EFF6FF"),
            in: RoundedRectangle(cornerRadius: MedsyRadius.sm, style: .continuous)
        )
        .clipped()
    }
}

private struct PrescriptionQuantityStepper: View {
    let quantity: Int
    let onDecrease: () -> Void
    let onIncrease: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            Button(action: onDecrease) {
                Image(systemName: "minus").frame(width: 34, height: 34)
            }

            Text("\(quantity)")
                .font(MedsyFont.button(13))
                .frame(width: 28, height: 34)

            Button(action: onIncrease) {
                Image(systemName: "plus")
                    .foregroundStyle(.white)
                    .frame(width: 34, height: 34)
                    .background(AppColor.green, in: Circle())
            }
        }
        .font(.system(size: 12, weight: .bold))
        .foregroundStyle(AppColor.textPrim)
        .background(AppColor.card, in: Capsule())
        .overlay(Capsule().stroke(AppColor.border, lineWidth: 1))
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
