import SwiftUI

struct CategoryGridCard: View {
    let category: Category
    let artworkHeight: CGFloat

    init(category: Category, artworkHeight: CGFloat = 150) {
        self.category = category
        self.artworkHeight = artworkHeight
    }

    var body: some View {
        VStack(spacing: MedsySpacing.xs) {
            CategoryArtworkView(category: category)
                .frame(height: artworkHeight)

            Text(category.displayName)
                .font(AppColor.sans(13, .semibold))
                .foregroundStyle(AppColor.textPrim)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, minHeight: 34, alignment: .top)
        }
        .frame(maxWidth: .infinity, minHeight: artworkHeight + 42, alignment: .top)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(category.displayName)
    }
}
