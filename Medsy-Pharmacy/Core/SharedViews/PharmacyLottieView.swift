//
//  PharmacyLottieView.swift
//  Medsy
//
//  Created by Shahudaa on 26/07/2026.
//


import SwiftUI
import Lottie

struct PharmacyLottieView: UIViewRepresentable {
	let name: String
	var loopMode: LottieLoopMode = .loop
	var speed: CGFloat = 1

	func makeUIView(context: Context) -> UIView {
		let container = UIView()

		let animationView = LottieAnimationView(name: name)
		animationView.translatesAutoresizingMaskIntoConstraints = false
		animationView.contentMode = .scaleAspectFit
		animationView.loopMode = loopMode
		animationView.animationSpeed = speed

		container.addSubview(animationView)

		NSLayoutConstraint.activate([
			animationView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
			animationView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
			animationView.topAnchor.constraint(equalTo: container.topAnchor),
			animationView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
		])

		animationView.play()

		return container
	}

	func updateUIView(_ uiView: UIView, context: Context) {}
}
