
//
//  TypingDotsView.swift
//  Medsy
//

import SwiftUI


struct TypingDotsView: View {

    var color: Color = MedsyTheme.default.primary
    var dotSize: CGFloat = 8
    var spacing: CGFloat = 5

    @State private var phase: Int = 0

    private let timer = Timer.publish(every: 0.35, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(color)
                    .frame(width: dotSize, height: dotSize)
                    .scaleEffect(phase == index ? 1.25 : 0.8)
                    .opacity(phase == index ? 1.0 : 0.4)
                    .animation(
                        .spring(response: 0.3, dampingFraction: 0.6),
                        value: phase
                    )
            }
        }
        .environment(\.layoutDirection, .leftToRight)
        .onReceive(timer) { _ in
            phase = (phase + 1) % 3
        }
    }
}

// MARK: - Preview

#Preview("Typing dots") {
    HStack {
        TypingDotsView()
    }
    .padding()
    .background(AppColor.surface)
    .clipShape(Capsule())
    .padding()
}
