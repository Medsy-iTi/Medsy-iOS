import Lottie
import SwiftUI

struct PharmacyLottieView: UIViewRepresentable {
    let animationName: String
    var loopMode: LottieLoopMode = .loop

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeUIView(context: Context) -> PharmacyLottieContainerView {
        let containerView = PharmacyLottieContainerView(
            animationName: animationName
        )
        containerView.update(
            loopMode: loopMode,
            reduceMotion: reduceMotion
        )
        return containerView
    }

    func updateUIView(
        _ containerView: PharmacyLottieContainerView,
        context: Context
    ) {
        containerView.update(
            loopMode: loopMode,
            reduceMotion: reduceMotion
        )
    }
}

final class PharmacyLottieContainerView: UIView {
    private let animationView: LottieAnimationView

    init(animationName: String) {
        animationView = LottieAnimationView(
            name: animationName,
            bundle: .main
        )
        super.init(frame: .zero)

        clipsToBounds = true
        layer.masksToBounds = true
        isUserInteractionEnabled = false

        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.contentMode = .scaleAspectFit
        animationView.clipsToBounds = true
        animationView.layer.masksToBounds = true
        animationView.backgroundBehavior = .pauseAndRestore

        addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: trailingAnchor),
            animationView.topAnchor.constraint(equalTo: topAnchor),
            animationView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        CGSize(
            width: UIView.noIntrinsicMetric,
            height: UIView.noIntrinsicMetric
        )
    }

    func update(loopMode: LottieLoopMode, reduceMotion: Bool) {
        animationView.loopMode = loopMode

        if reduceMotion {
            animationView.stop()
            animationView.currentProgress = 0.5
        } else if !animationView.isAnimationPlaying {
            animationView.play()
        }
    }
}
