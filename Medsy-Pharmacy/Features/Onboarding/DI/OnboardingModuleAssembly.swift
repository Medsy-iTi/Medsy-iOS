//
//  OnboardingModuleAssembly.swift
//  Medsy-Pharmacy
//
//

import Foundation

struct OnboardingModuleAssembly: PharmacyModuleAssembly {
    func register(in container: PharmacyDIContainer) {
        container.register(OnboardingStatusStoring.self) { _ in
            UserDefaultsOnboardingStatusStore()
        }

        container.register(OnboardingRepositoryProtocol.self) { _ in
            OnboardingRepository()
        }

        container.register(GetOnboardingPagesUseCaseProtocol.self) { container in
            GetOnboardingPagesUseCase(repository: container.resolve(OnboardingRepositoryProtocol.self))
        }

        container.register(CompleteOnboardingUseCaseProtocol.self) { container in
            CompleteOnboardingUseCase(statusStore: container.resolve(OnboardingStatusStoring.self))
        }

        container.register(HasCompletedOnboardingUseCaseProtocol.self) { container in
            HasCompletedOnboardingUseCase(statusStore: container.resolve(OnboardingStatusStoring.self))
        }
    }
}
