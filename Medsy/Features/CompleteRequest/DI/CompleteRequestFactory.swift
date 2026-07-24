//
//  CompleteRequestFactory.swift
//  Medsy
//
//  Created by Ehab Salah on 24/07/2026.
//

@MainActor
final class CompleteRequestFactory {
    private let getCustomerProfileUseCase: GetCustomerProfileUseCaseProtocol
    private let searchAddressUseCase: SearchAddressUseCaseProtocol
    private let reverseGeocodeAddressUseCase: ReverseGeocodeAddressUseCaseProtocol
    private let locationProvider: CompleteRequestLocationProviderProtocol

    init(
        getCustomerProfileUseCase: GetCustomerProfileUseCaseProtocol,
        searchAddressUseCase: SearchAddressUseCaseProtocol,
        reverseGeocodeAddressUseCase: ReverseGeocodeAddressUseCaseProtocol,
        locationProvider: CompleteRequestLocationProviderProtocol
    ) {
        self.getCustomerProfileUseCase = getCustomerProfileUseCase
        self.searchAddressUseCase = searchAddressUseCase
        self.reverseGeocodeAddressUseCase = reverseGeocodeAddressUseCase
        self.locationProvider = locationProvider
    }

    func makeViewModel(
        draft: CompleteRequestDraft,
        onSubmit: @escaping (CompleteRequestSubmission) async -> Bool
    ) -> CompleteRequestViewModel {
        CompleteRequestViewModel(
            draft: draft,
            getCustomerProfileUseCase: getCustomerProfileUseCase,
            onSubmit: onSubmit
        )
    }

    func makeLocationPickerViewModel(
        initialLocation: CompleteRequestLocation?,
        initialAddress: String?
    ) -> CompleteRequestLocationPickerViewModel {
        CompleteRequestLocationPickerViewModel(
            initialLocation: initialLocation,
            initialAddress: initialAddress,
            searchAddressUseCase: searchAddressUseCase,
            reverseGeocodeAddressUseCase: reverseGeocodeAddressUseCase,
            locationProvider: locationProvider
        )
    }
}
