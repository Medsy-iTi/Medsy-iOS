//
//  OnboardingAssembly.swift
//  Medsy
//
//  Created by Ehab Salah on 15/07/2026.
//

struct OnboardingAssembly: ModuleAssembly {
    func register(in container: DIContainer) {
        container.register(OnboardingStatusRepository.self) { _ in
            UserDefaultsOnboardingStatusRepository()
        }

        container.register(ShouldShowOnboardingUseCase.self) { container in
            ShouldShowOnboardingUseCase(
                repository: container.resolve(OnboardingStatusRepository.self)
            )
        }

        container.register(CompleteOnboardingUseCase.self) { container in
            CompleteOnboardingUseCase(
                repository: container.resolve(OnboardingStatusRepository.self)
            )
        }

        container.register(OnboardingFactory.self) { container in
            OnboardingFactory(
                shouldShowOnboarding: container.resolve(ShouldShowOnboardingUseCase.self),
                completeOnboarding: container.resolve(CompleteOnboardingUseCase.self)
            )
        }
    }
}
