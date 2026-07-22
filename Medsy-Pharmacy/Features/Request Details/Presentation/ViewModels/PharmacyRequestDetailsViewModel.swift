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
        print("[PharmacyRequestDetails] 🚀 Opened screen & starting backend fetch")
        state = .loading
        do {
            if let requestId {
                print("[PharmacyRequestDetails] 📡 Requesting details for Order ID: \(requestId)")
                let entity = try await useCase.execute(requestId: requestId)
                self.requestModel = PharmacyRequestDetailsMapper.mapToPresentationModel(entity)
                self.state = .loaded
                print("[PharmacyRequestDetails] ✅ Success: Loaded order details for ID \(entity.id)")
            } else if let pharmacyId = identityProvider?.currentPharmacyId {
                print("[PharmacyRequestDetails] 📡 Requesting orders for Pharmacy ID: \(pharmacyId)")
                let list = try await useCase.execute(pharmacyId: pharmacyId, page: 0, size: 10)
                if let first = list.first {
                    self.requestModel = PharmacyRequestDetailsMapper.mapToPresentationModel(first)
                    self.state = .loaded
                    print("[PharmacyRequestDetails] ✅ Success: Loaded request ID \(first.id) from pharmacy orders")
                } else {
                    self.state = .failed("No requests found")
                    print("[PharmacyRequestDetails] ⚠️ Warning: No requests found for pharmacy ID \(pharmacyId)")
                }
            } else {
                self.state = .failed("No request ID or pharmacy ID provided")
                print("[PharmacyRequestDetails] ❌ Error: Neither requestId nor pharmacyId provided")
            }
        } catch {
            let errMsg = (error as? NetworkError)?.errorDescription ?? error.localizedDescription
            self.state = .failed(errMsg)
            print("[PharmacyRequestDetails] ❌ Request failed with error: \(error)")
        }
    }
}
