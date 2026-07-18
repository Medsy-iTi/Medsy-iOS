//
//  OnboardingRepository.swift
//  Medsy-Pharmacy
//
//

import Foundation

protocol OnboardingRepositoryProtocol {
    func fetchPages() -> [OnboardingPage]
}

struct OnboardingRepository: OnboardingRepositoryProtocol {
    func fetchPages() -> [OnboardingPage] {
        [
            OnboardingPage(
                id: 0,
                imageName: "onboarding_appointments",
                titleKey: "pharmacy.onboarding.page1.title",
                subtitleKey: "pharmacy.onboarding.page1.subtitle",
                primaryActionKey: "pharmacy.onboarding.next"
            ),
            OnboardingPage(
                id: 1,
                imageName: "onboarding_patient_security",
                titleKey: "pharmacy.onboarding.page2.title",
                subtitleKey: "pharmacy.onboarding.page2.subtitle",
                primaryActionKey: "pharmacy.onboarding.next"
            ),
            OnboardingPage(
                id: 2,
                imageName: "onboarding_performance",
                titleKey: "pharmacy.onboarding.page3.title",
                subtitleKey: "pharmacy.onboarding.page3.subtitle",
                primaryActionKey: "pharmacy.onboarding.get_started"
            )
        ]
    }
}
