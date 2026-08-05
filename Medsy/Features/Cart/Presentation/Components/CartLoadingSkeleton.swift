import SwiftUI

struct CartLoadingSkeleton: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: MedsySpacing.lg) {
                VStack(alignment: .leading, spacing: MedsySpacing.xs) {
                    MedsyShimmerBlock().frame(width: 170, height: 28)
                    MedsyShimmerBlock().frame(width: 235, height: 15)
                }

                MedsyShimmerBlock(cornerRadius: MedsyRadius.md)
                    .frame(height: 52)

                VStack(spacing: MedsySpacing.sm) {
                    ForEach(0..<3, id: \.self) { _ in
                        VStack(alignment: .leading, spacing: MedsySpacing.sm) {
                            HStack(alignment: .top, spacing: MedsySpacing.md) {
                                MedsyShimmerBlock(cornerRadius: MedsyRadius.md)
                                    .frame(width: 56, height: 56)

                                VStack(alignment: .leading, spacing: MedsySpacing.xs) {
                                    MedsyShimmerBlock().frame(width: 130, height: 17)
                                    MedsyShimmerBlock().frame(width: 82, height: 13)
                                }

                                Spacer(minLength: MedsySpacing.sm)

                                VStack(alignment: .trailing, spacing: MedsySpacing.xs) {
                                    MedsyShimmerBlock().frame(width: 74, height: 16)
                                    MedsyShimmerBlock().frame(width: 62, height: 12)
                                }
                            }

                            HStack {
                                MedsyShimmerBlock(cornerRadius: 18)
                                    .frame(width: 116, height: 36)

                                Spacer()

                                MedsyShimmerBlock(cornerRadius: 19)
                                    .frame(width: 38, height: 38)
                            }
                        }
                        .padding(MedsySpacing.md)
                        .background(AppColor.card)
                        .overlay(
                            RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous)
                                .stroke(AppColor.border, lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous))
                    }
                }

                VStack(spacing: MedsySpacing.sm) {
                    HStack {
                        MedsyShimmerBlock().frame(width: 110, height: 15)
                        Spacer()
                        MedsyShimmerBlock().frame(width: 84, height: 17)
                    }

                    MedsyShimmerBlock(cornerRadius: MedsyRadius.md)
                        .frame(height: 52)
                }
                .padding(MedsySpacing.md)
                .background(AppColor.card)
                .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous))
            }
            .padding(.horizontal, MedsySpacing.md)
            .padding(.top, MedsySpacing.md)
            .padding(.bottom, 112)
        }
        .accessibilityLabel("common.loading".localized)
    }
}
