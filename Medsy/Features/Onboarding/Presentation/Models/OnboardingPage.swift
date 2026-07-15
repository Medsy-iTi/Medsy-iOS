//
//  OnboardingPage.swift
//  Medsy
//
//  Created by Ehab Salah on 15/07/2026.
//

struct OnboardingPage: Identifiable, Equatable {
    let id: Int
    let imageName: String
    let titleKey: String
    let bodyKey: String

    static let pages = [
        OnboardingPage(
            id: 0,
            imageName: "OnboardingOrder",
            titleKey: "onboarding.order.title",
            bodyKey: "onboarding.order.body"
        ),
        OnboardingPage(
            id: 1,
            imageName: "OnboardingDelivery",
            titleKey: "onboarding.delivery.title",
            bodyKey: "onboarding.delivery.body"
        ),
        OnboardingPage(
            id: 2,
            imageName: "OnboardingTrust",
            titleKey: "onboarding.trust.title",
            bodyKey: "onboarding.trust.body"
        )
    ]
}
