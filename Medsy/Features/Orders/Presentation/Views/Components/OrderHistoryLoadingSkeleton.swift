import SwiftUI

struct OrderHistoryLoadingSkeleton: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: MedsySpacing.md) {
                OrderSkeletonBlock(width: 92, height: 14)

                ForEach(0..<4, id: \.self) { _ in
                    VStack(alignment: .leading, spacing: MedsySpacing.xs) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 6) {
                                OrderSkeletonBlock(width: 82, height: 18)
                                OrderSkeletonBlock(width: 110, height: 12)
                            }

                            Spacer(minLength: 0)
                            OrderSkeletonBlock(width: 14, height: 18)
                        }

                        OrderSkeletonBlock(width: 96, height: 15)
                        OrderSkeletonBlock(width: 74, height: 14, cornerRadius: 7)
                        OrderSkeletonBlock(width: 180, height: 13)

                        HStack(alignment: .bottom) {
                            HStack(spacing: -MedsySpacing.xxs) {
                                ForEach(0..<3, id: \.self) { _ in
                                    OrderSkeletonBlock(
                                        width: 40,
                                        height: 40,
                                        cornerRadius: MedsyRadius.sm
                                    )
                                }
                            }

                            Spacer(minLength: 0)

                            VStack(alignment: .trailing, spacing: 5) {
                                OrderSkeletonBlock(width: 76, height: 16)
                                OrderSkeletonBlock(width: 58, height: 12)
                            }
                        }
                    }
                    .padding(MedsySpacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppColor.card)
                    .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous)
                            .stroke(AppColor.border, lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal, MedsySpacing.md)
            .padding(.top, MedsySpacing.md)
            .padding(.bottom, MedsySpacing.xxl + 80)
        }
        .accessibilityLabel("orders.loading".localized)
    }
}
