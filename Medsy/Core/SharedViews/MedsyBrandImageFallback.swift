import SwiftUI

struct MedsyBrandImageFallback: View {
    var logoScale: CGFloat = 0.56

    var body: some View {
        GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height)

            Image("SplashLogo")
                .resizable()
                .scaledToFit()
                .frame(
                    width: side * logoScale,
                    height: side * logoScale
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .accessibilityHidden(true)
    }
}
