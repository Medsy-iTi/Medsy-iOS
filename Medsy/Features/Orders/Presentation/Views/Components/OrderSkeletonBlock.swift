import SwiftUI

struct OrderSkeletonBlock: View {
    let width: CGFloat?
    let height: CGFloat
    let cornerRadius: CGFloat

    @State private var isHighlighted = false

    init(
        width: CGFloat? = nil,
        height: CGFloat,
        cornerRadius: CGFloat = MedsyRadius.sm
    ) {
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(AppColor.skeleton)
            .frame(width: width, height: height)
            .opacity(isHighlighted ? 0.45 : 1)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.85).repeatForever(autoreverses: true)) {
                    isHighlighted = true
                }
            }
            .accessibilityHidden(true)
    }
}
