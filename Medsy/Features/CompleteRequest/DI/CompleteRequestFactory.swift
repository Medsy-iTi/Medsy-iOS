//
//  CompleteRequestFactory.swift
//  Medsy
//
//  Created by Ehab Salah on 24/07/2026.
//

@MainActor
final class CompleteRequestFactory {
    private let getCustomerProfileUseCase: GetCustomerProfileUseCaseProtocol
    private let submitCompleteRequestUseCase: SubmitCompleteRequestUseCaseProtocol
    private let searchAddressUseCase: SearchAddressUseCaseProtocol
    private let reverseGeocodeAddressUseCase: ReverseGeocodeAddressUseCaseProtocol
    private let locationProvider: CompleteRequestLocationProviderProtocol
    private let statusStore: UserDefaultsStatusStoreProtocol?

    init(
        getCustomerProfileUseCase: GetCustomerProfileUseCaseProtocol,
        submitCompleteRequestUseCase: SubmitCompleteRequestUseCaseProtocol,
        searchAddressUseCase: SearchAddressUseCaseProtocol,
        reverseGeocodeAddressUseCase: ReverseGeocodeAddressUseCaseProtocol,
        locationProvider: CompleteRequestLocationProviderProtocol,
        statusStore: UserDefaultsStatusStoreProtocol? = nil
    ) {
        self.getCustomerProfileUseCase = getCustomerProfileUseCase
        self.submitCompleteRequestUseCase = submitCompleteRequestUseCase
        self.searchAddressUseCase = searchAddressUseCase
        self.reverseGeocodeAddressUseCase = reverseGeocodeAddressUseCase
        self.locationProvider = locationProvider
        self.statusStore = statusStore
    }

    func makeViewModel(
        draft: CompleteRequestDraft,
        onSubmit: @escaping (CompleteRequestSubmission) async -> Bool
    ) -> CompleteRequestViewModel {
        CompleteRequestViewModel(
            draft: draft,
            getCustomerProfileUseCase: getCustomerProfileUseCase,
            submitCompleteRequestUseCase: submitCompleteRequestUseCase,
            statusStore: statusStore,
            onRequestCreated: onSubmit
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
