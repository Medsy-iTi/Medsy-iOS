//
//  MedsyLottieView.swift
//  Medsy
//
//  Created by Codex on 26/07/2026.
//

import Lottie
import SwiftUI
import UIKit

struct MedsyLottieView: UIViewRepresentable {
    let animationName: String
    var loopMode: LottieLoopMode = .loop
    var contentMode: UIView.ContentMode = .scaleAspectFit

    func makeUIView(context: Context) -> LottieAnimationView {
        let animationView = LottieAnimationView()
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.contentMode = contentMode
        animationView.loopMode = loopMode
        animationView.animation = loadAnimation()
        animationView.play()
        return animationView
    }

    func updateUIView(_ animationView: LottieAnimationView, context: Context) {
        animationView.contentMode = contentMode
        animationView.loopMode = loopMode

        if animationView.animation == nil {
            animationView.animation = loadAnimation()
        }

        if !animationView.isAnimationPlaying {
            animationView.play()
        }
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
