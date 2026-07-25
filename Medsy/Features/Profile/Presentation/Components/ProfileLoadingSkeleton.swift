import SwiftUI

struct ProfileHeaderLoadingSkeleton: View {
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(ProfileStyle.border.opacity(0.72))
                .frame(width: 64, height: 64)

            VStack(alignment: .leading, spacing: 9) {
                ProfileSkeletonBlock(width: 142, height: 15)
                ProfileSkeletonBlock(width: 104, height: 11)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 21)
        .padding(.vertical, 17)
        .background(ProfileStyle.card)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(ProfileStyle.border, lineWidth: 1)
        }
        .profileShimmer()
        .accessibilityLabel("profile.loading".localized)
    }
}

struct ProfileDetailsLoadingSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ProfileSkeletonBlock(width: 92, height: 10)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                ForEach(0..<4, id: \.self) { index in
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(ProfileStyle.border.opacity(0.72))
                            .frame(width: 34, height: 34)

                        VStack(alignment: .leading, spacing: 6) {
                            ProfileSkeletonBlock(width: 72, height: 9)
                            ProfileSkeletonBlock(width: index.isMultiple(of: 2) ? 154 : 118, height: 12)
                        }

                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)

                    if index < 3 {
                        Divider()
                            .background(ProfileStyle.border)
                            .padding(.leading, 56)
                    }
                }
            }
            .background(ProfileStyle.card)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(ProfileStyle.border, lineWidth: 1)
            }
            .profileShimmer()
        }
        .accessibilityLabel("profile.loading".localized)
    }
}

private struct ProfileSkeletonBlock: View {
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: height / 2, style: .continuous)
            .fill(ProfileStyle.border.opacity(0.72))
            .frame(width: width, height: height)
    }
}

private struct ProfileShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { geometry in
                    LinearGradient(
                        colors: [.clear, Color.white.opacity(0.22), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 0.7)
                    .offset(x: phase * geometry.size.width * 1.7)
                }
                .allowsHitTesting(false)
            }
            .clipped()
            .onAppear {
                withAnimation(.linear(duration: 1.15).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

private extension View {
    func profileShimmer() -> some View {
        modifier(ProfileShimmerModifier())
    }
}
