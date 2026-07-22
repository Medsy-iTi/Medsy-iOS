//  PharmacyRequestDetailsViewModel.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 23/07/2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class PharmacyRequestDetailsViewModel {
    enum State: Equatable {
        case idle
        case loading
        case loaded
        case failed(String)
    }

    private(set) var state: State = .idle
    var requestModel: PharmacyRequestDetailsModel?
    let requestId: Int?

    private let useCase: FetchPharmacyRequestDetailsUseCaseProtocol
    private let identityProvider: PharmacyIdentityProviding?

    init(
        requestId: Int? = nil,
        useCase: FetchPharmacyRequestDetailsUseCaseProtocol,
        identityProvider: PharmacyIdentityProviding? = nil
    ) {
        self.requestId = requestId
        self.useCase = useCase
        self.identityProvider = identityProvider
    }

    func loadDetails() async {
        state = .loading
        do {
            if let requestId {
                let entity = try await useCase.execute(requestId: requestId)
                self.requestModel = PharmacyRequestDetailsMapper.mapToPresentationModel(entity)
                self.state = .loaded
            } else if let pharmacyId = identityProvider?.currentPharmacyId {
                let list = try await useCase.execute(pharmacyId: pharmacyId, page: 0, size: 10)
                if let first = list.first {
                    self.requestModel = PharmacyRequestDetailsMapper.mapToPresentationModel(first)
                    self.state = .loaded
                } else {
                    self.state = .failed("No requests found")
                }
            } else {
                self.state = .failed("No request ID or pharmacy ID provided")
            }
        } catch {
            self.state = .failed((error as? NetworkError)?.errorDescription ?? error.localizedDescription)
        }
    }
}
