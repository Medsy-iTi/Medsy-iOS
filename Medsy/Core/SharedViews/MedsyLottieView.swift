//
//  MedsyLottieView.swift
//  Medsy
//
//  Created by Ahmed Elkady on 26/07/2026.
//

import Lottie
import SwiftUI
import UIKit

struct MedsyLottieView: UIViewRepresentable {
    let animationName: String
    var loopMode: LottieLoopMode = .loop
    var contentMode: UIView.ContentMode = .scaleAspectFit
    var animationSpeed: CGFloat = 1
    var clipsToBounds = false
    var tintColor: UIColor?

    func makeUIView(context: Context) -> MedsyLottieContainerView {
        let containerView = MedsyLottieContainerView()
        updateUIView(containerView, context: context)
        return containerView
    }

    func updateUIView(_ containerView: MedsyLottieContainerView, context: Context) {
        containerView.update(
            animation: loadAnimation(),
            loopMode: loopMode,
            contentMode: contentMode,
            animationSpeed: animationSpeed,
            clipsToBounds: clipsToBounds,
            tintColor: tintColor
        )
    }

    private func loadAnimation() -> LottieAnimation? {
        if let path = Bundle.main.path(forResource: animationName, ofType: "json") {
            return LottieAnimation.filepath(path)
        }

        if let path = Bundle.main.path(
            forResource: animationName,
            ofType: "json",
            inDirectory: "Resources/Animations"
        ) {
            return LottieAnimation.filepath(path)
        }

        return LottieAnimation.named(animationName)
    }
}

final class MedsyLottieContainerView: UIView {
    private let animationView = LottieAnimationView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        isUserInteractionEnabled = false
        clipsToBounds = true
        layer.masksToBounds = true

        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.clipsToBounds = true
        animationView.layer.masksToBounds = true

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
        CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
    }

    func update(
        animation: LottieAnimation?,
        loopMode: LottieLoopMode,
        contentMode: UIView.ContentMode,
        animationSpeed: CGFloat,
        clipsToBounds: Bool,
        tintColor: UIColor?
    ) {
        self.clipsToBounds = true
        layer.masksToBounds = true

        animationView.contentMode = contentMode
        animationView.clipsToBounds = clipsToBounds
        animationView.layer.masksToBounds = clipsToBounds
        animationView.loopMode = loopMode
        animationView.animationSpeed = animationSpeed

        if animationView.animation == nil {
            animationView.animation = animation
        }
        applyTint(tintColor)

        if !animationView.isAnimationPlaying {
            animationView.play()
        }
    }

    private func applyTint(_ tintColor: UIColor?) {
        guard let tintColor else { return }

        let lottieColor = LottieColor(
            r: Double(tintColor.rgba.red),
            g: Double(tintColor.rgba.green),
            b: Double(tintColor.rgba.blue),
            a: Double(tintColor.rgba.alpha)
        )
        animationView.setValueProvider(
            ColorValueProvider(lottieColor),
            keypath: AnimationKeypath(keypath: "**.Color")
        )
    }
}

private extension UIColor {
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (red, green, blue, alpha)
    }
}
