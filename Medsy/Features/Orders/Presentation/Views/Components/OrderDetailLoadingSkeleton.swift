import SwiftUI

struct OrderDetailLoadingSkeleton: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: MedsySpacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: MedsySpacing.xs) {
                        OrderSkeletonBlock(width: 116, height: 20)
                        OrderSkeletonBlock(width: 92, height: 13)
                    }

                    Spacer(minLength: 0)
                    OrderSkeletonBlock(width: 88, height: 28, cornerRadius: 14)
                }
                .padding(MedsySpacing.md)
                .background(AppColor.card)
                .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous)
                        .stroke(AppColor.border, lineWidth: 1)
                )

                HStack(spacing: MedsySpacing.sm) {
                    OrderSkeletonBlock(width: 44, height: 44, cornerRadius: 22)

                    VStack(alignment: .leading, spacing: 6) {
                        OrderSkeletonBlock(width: 72, height: 12)
                        OrderSkeletonBlock(width: 156, height: 16)
                    }

                    Spacer(minLength: 0)
                    OrderSkeletonBlock(width: 12, height: 18)
                }
                .padding(MedsySpacing.md)
                .background(AppColor.card)
                .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous)
                        .stroke(AppColor.border, lineWidth: 1)
                )

                VStack(alignment: .leading, spacing: MedsySpacing.xs) {
                    OrderSkeletonBlock(width: 104, height: 16)

                    VStack(spacing: 0) {
                        ForEach(0..<3, id: \.self) { index in
                            HStack(spacing: MedsySpacing.sm) {
                                OrderSkeletonBlock(
                                    width: 48,
                                    height: 48,
                                    cornerRadius: MedsyRadius.sm
                                )

                                VStack(alignment: .leading, spacing: 6) {
                                    OrderSkeletonBlock(width: 150, height: 14)
                                    OrderSkeletonBlock(width: 112, height: 12)
                                }

                                Spacer(minLength: 0)
                                OrderSkeletonBlock(width: 58, height: 14)
                            }
                            .padding(.horizontal, MedsySpacing.md)
                            .padding(.vertical, MedsySpacing.sm)

                            if index < 2 {
                                Divider()
                                    .background(AppColor.border)
                                    .padding(.leading, 56 + MedsySpacing.md)
                            }
                        }
                    }
                    .background(AppColor.card)
                    .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous)
                            .stroke(AppColor.border, lineWidth: 1)
                    )
                }

                VStack(alignment: .leading, spacing: MedsySpacing.sm) {
                    OrderSkeletonBlock(width: 126, height: 16)

                    ForEach(0..<3, id: \.self) { _ in
                        HStack {
                            OrderSkeletonBlock(width: 112, height: 14)
                            Spacer(minLength: 0)
                            OrderSkeletonBlock(width: 76, height: 14)
                        }
                    }
                }
                .padding(MedsySpacing.md)
                .background(AppColor.card)
                .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous)
                        .stroke(AppColor.border, lineWidth: 1)
                )
            }
            .padding(MedsySpacing.md)
            .padding(.bottom, 96)
        }
        .accessibilityLabel("orders.loading".localized)
    }
}
