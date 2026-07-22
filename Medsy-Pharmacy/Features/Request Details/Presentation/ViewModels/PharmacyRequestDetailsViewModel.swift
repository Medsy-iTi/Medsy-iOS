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
    let requestId: Int

    private let useCase: FetchPharmacyRequestDetailsUseCaseProtocol

    init(
        requestId: Int,
        useCase: FetchPharmacyRequestDetailsUseCaseProtocol
    ) {
        self.requestId = requestId
        self.useCase = useCase
    }

    func loadDetails() async {
        print("[PharmacyRequestDetails] 🚀 Opened screen & starting backend fetch")
        state = .loading
        do {
            print("[PharmacyRequestDetails] 📡 Requesting details for Order ID: \(requestId)")
            let entity = try await useCase.execute(requestId: requestId)
            self.requestModel = PharmacyRequestDetailsMapper.mapToPresentationModel(entity)
            self.state = .loaded
            print("[PharmacyRequestDetails] ✅ Success: Loaded order details for ID \(entity.id)")
        } catch {
            let errMsg = (error as? NetworkError)?.errorDescription ?? error.localizedDescription
            self.state = .failed(errMsg)
            print("[PharmacyRequestDetails] ❌ Request failed with error: \(error)")
        }
    }
}
