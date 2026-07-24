//
//  CompleteRequestAssembly.swift
//  Medsy
//
//  Created by Ehab Salah on 24/07/2026.
//

struct CompleteRequestAssembly: ModuleAssembly {
    func register(in container: DIContainer) {
        container.register(CompleteRequestLocationProviderProtocol.self) { _ in
            MainActor.assumeIsolated {
                CompleteRequestLocationProvider()
            }
        }

        container.register(CompleteRequestFactory.self) { container in
            MainActor.assumeIsolated {
                CompleteRequestFactory(
                    getCustomerProfileUseCase: container.resolve(GetCustomerProfileUseCaseProtocol.self),
                    searchAddressUseCase: container.resolve(SearchAddressUseCaseProtocol.self),
                    reverseGeocodeAddressUseCase: container.resolve(ReverseGeocodeAddressUseCaseProtocol.self),
                    locationProvider: container.resolve(CompleteRequestLocationProviderProtocol.self)
                )
            }
        }
    }
}
