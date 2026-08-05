import SwiftUI

struct CategoryProductCardSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: MedsySpacing.xs) {
            MedsySkeletonBlock(cornerRadius: MedsyRadius.md, height: 126)
            MedsySkeletonBlock(cornerRadius: MedsyRadius.sm, height: 16)
            MedsySkeletonBlock(cornerRadius: MedsyRadius.sm, height: 16, width: 110)
            MedsySkeletonBlock(cornerRadius: MedsyRadius.sm, height: 12, width: 82)
            Spacer(minLength: 0)
            MedsySkeletonBlock(cornerRadius: MedsyRadius.sm, height: 18, width: 72)
            MedsySkeletonBlock(cornerRadius: MedsyRadius.md, height: 42)
        }
        .padding(MedsySpacing.sm)
        .frame(maxWidth: .infinity, minHeight: 310, alignment: .topLeading)
        .background {
            RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous)
                .fill(AppColor.card)
                .overlay {
                    RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous)
                        .stroke(AppColor.border, lineWidth: 1)
                }
        }
    }
}
