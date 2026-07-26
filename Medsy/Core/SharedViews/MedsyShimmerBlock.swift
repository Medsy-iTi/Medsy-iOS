import SwiftUI

struct MedsyShimmerBlock: View {
    var cornerRadius: CGFloat = MedsyRadius.sm

    @State private var phase: CGFloat = -1

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(AppColor.skeleton)
            .overlay {
                GeometryReader { geometry in
                    LinearGradient(
                        colors: [
                            .clear,
                            Color.white.opacity(0.38),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 1.4)
                    .offset(x: phase * geometry.size.width * 1.8)
                }
                .clipped()
            }
            .onAppear {
                withAnimation(.linear(duration: 1.15).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
            .accessibilityHidden(true)
    }
}
