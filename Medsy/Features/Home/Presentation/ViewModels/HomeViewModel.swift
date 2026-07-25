//
//  HomeViewModel.swift
//  Medsy
//
//  Created by Antoneos Philip on 25/07/2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel {
    var selectedStatus: HomeSearchStatus = .home
    private(set) var offerResult: OfferResult?
    private(set) var activeRequestId: Int?

    private let getOfferResultUseCase: GetOfferResultUseCaseProtocol
    private let statusStore: UserDefaultsStatusStoreProtocol
    private var pollingTask: Task<Void, Never>?

    init(
        getOfferResultUseCase: GetOfferResultUseCaseProtocol = DIContainer.shared.resolve(GetOfferResultUseCaseProtocol.self),
        statusStore: UserDefaultsStatusStoreProtocol = DIContainer.shared.resolve(UserDefaultsStatusStoreProtocol.self)
    ) {
        self.getOfferResultUseCase = getOfferResultUseCase
        self.statusStore = statusStore
    }

    func checkAndStartPolling() {
        guard let pendingId = statusStore.pendingRequestId else {
            if offerResult == nil {
                selectedStatus = .home
            }
            return
        }

        activeRequestId = pendingId
        if offerResult == nil {
            selectedStatus = .searching
        }

        guard pollingTask == nil else { return }

        pollingTask = Task {
            while !Task.isCancelled {
                guard let reqId = statusStore.pendingRequestId else {
                    break
                }

                do {
                    let result = try await getOfferResultUseCase.execute(requestId: reqId)
                    if !Task.isCancelled {
                        if result.isAvailable {
                            self.offerResult = result
                            self.selectedStatus = .firstOffer
                            break
                        } else {
                            if self.offerResult == nil {
                                self.selectedStatus = .searching
                            }
                        }
                    }
                } catch {
                    // Do not show error UI for temporary failures, keep polling searching state
                    if self.offerResult == nil {
                        self.selectedStatus = .searching
                    }
                }

                do {
                    try await Task.sleep(for: .seconds(60))
                } catch {
                    break
                }
            }
            pollingTask = nil
        }
    }

    func stopPolling() {
        pollingTask?.cancel()
        pollingTask = nil
    }

    func clearActiveRequest() {
        stopPolling()
        statusStore.clearPendingRequestId()
        activeRequestId = nil
        offerResult = nil
        selectedStatus = .home
    }
}
