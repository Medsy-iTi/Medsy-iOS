import SwiftUI

struct CategoryGridCard: View {
    let category: Category

    var body: some View {
        VStack(spacing: MedsySpacing.xs) {
            CategoryArtworkView(category: category)

            Text(category.displayName)
                .font(AppColor.sans(13, .semibold))
                .foregroundStyle(AppColor.textPrim)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, minHeight: 34, alignment: .top)
        }
        .frame(maxWidth: .infinity, alignment: .top)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(category.displayName)
    }
}
