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
    private(set) var offerResults: [Int: OfferResult] = [:]
    private(set) var activeRequestIds: [Int] = []

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

    // MARK: - Computed properties for UI

    var firstAvailableOfferResult: OfferResult? {
        offerResults.values.first(where: { $0.isAvailable })
    }

    var firstAvailableRequestId: Int? {
        offerResults.first(where: { $0.value.isAvailable })?.key
    }

    var offerTotalPrice: Double {
        firstAvailableOfferResult?.totalPrice ?? 0
    }

    var offerAvailableMedsCount: Int {
        firstAvailableOfferResult?.items.filter(\.isAvailable).count ?? 0
    }

    var offerTotalMedsCount: Int {
        firstAvailableOfferResult?.items.count ?? 0
    }

    // MARK: - Polling

    func checkAndStartPolling() {
        var pendingIds = statusStore.pendingRequestIds
        // Check for requests older than 5 minutes (300 seconds) and expire them immediately (Disabled as per user request)
        /*
        for reqId in pendingIds {
            if let age = statusStore.getRequestAgeInSeconds(reqId), age > 300 {
                statusStore.clearPendingRequestId(reqId)
            }
        }
        */
        
        pendingIds = statusStore.pendingRequestIds
        guard !pendingIds.isEmpty else {
            activeRequestIds = []
            offerResults = [:]
            selectedStatus = .home
            stopPolling()
            return
        }

        activeRequestIds = pendingIds
        // Clean up any old offer results that are no longer pending
        for reqId in offerResults.keys {
            if !pendingIds.contains(reqId) {
                offerResults.removeValue(forKey: reqId)
            }
        }

        if offerResults.values.first(where: { $0.isAvailable }) == nil {
            selectedStatus = .searching
        }

        guard pollingTask == nil else { return }

        pollingTask = Task {
            while !Task.isCancelled {
                var ids = statusStore.pendingRequestIds
                // Clean up expired requests in background loop (Disabled as per user request)
                /*
                var expiredIds: [Int] = []
                for reqId in ids {
                    if let age = statusStore.getRequestAgeInSeconds(reqId), age > 300 {
                        expiredIds.append(reqId)
                    }
                }
                for reqId in expiredIds {
                    statusStore.clearPendingRequestId(reqId)
                    offerResults.removeValue(forKey: reqId)
                    activeRequestIds.removeAll { $0 == reqId }
                }
                */
                
                ids = statusStore.pendingRequestIds
                guard !ids.isEmpty else {
                    selectedStatus = .home
                    break
                }

                await withTaskGroup(of: (Int, OfferResult?, Bool).self) { group in
                    for reqId in ids {
                        group.addTask {
                            do {
                                let result = try await self.getOfferResultUseCase.execute(requestId: reqId)
                                return (reqId, result, false)
                            } catch {
                                var isExpired = false
                                if case let NetworkError.validationError(message) = error {
                                    isExpired = message.localizedCaseInsensitiveContains("EXPIRED")
                                }
                                return (reqId, nil, isExpired)
                            }
                        }
                    }

                    for await (reqId, result, isExpired) in group {
                        if Task.isCancelled { return }
                        if isExpired {
                            self.statusStore.clearPendingRequestId(reqId)
                            self.offerResults.removeValue(forKey: reqId)
                            self.activeRequestIds.removeAll { $0 == reqId }
                        } else if let result, result.isAvailable {
                            self.offerResults[reqId] = result
                        }
                    }
                }

                if !Task.isCancelled {
                    let currentPendingIds = statusStore.pendingRequestIds
                    if currentPendingIds.isEmpty {
                        self.selectedStatus = .home
                        break
                    } else if offerResults.values.contains(where: { $0.isAvailable }) {
                        self.selectedStatus = .firstOffer
                        break
                    } else {
                        self.selectedStatus = .searching
                    }
                }

                do {
                    try await Task.sleep(for: .seconds(30))
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
        activeRequestIds = []
        offerResults = [:]
        selectedStatus = .home
    }

    func clearCompletedRequest(requestId: Int) {
        statusStore.clearPendingRequestId(requestId)
        offerResults.removeValue(forKey: requestId)
        activeRequestIds.removeAll { $0 == requestId }
        if activeRequestIds.isEmpty {
            selectedStatus = .home
            stopPolling()
        }
    }
}
