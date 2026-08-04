import SwiftUI

struct CategoryArtworkView: View {
    let category: Category

    var body: some View {
        Group {
            if let artworkName = category.artworkName {
                Image(artworkName)
                    .resizable()
                    .scaledToFit()
            } else {
                MedsyBrandImageFallback(logoScale: 0.55)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .background(category.bgColor)
        .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous)
                .stroke(AppColor.border.opacity(0.55), lineWidth: 1)
        }
        .medsyCardShadow()
        .accessibilityHidden(true)
    }
}
