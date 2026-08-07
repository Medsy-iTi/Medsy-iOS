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
        let allIds = statusStore.pendingRequestIds
        for reqId in allIds {
            if let age = statusStore.getRequestAgeInSeconds(reqId), age > 900 {
                statusStore.clearPendingRequestId(reqId)
                offerResults.removeValue(forKey: reqId)
            }
        }

        let pendingIds = statusStore.pendingRequestIds
        guard !pendingIds.isEmpty else {
            activeRequestIds = []
            offerResults = [:]
            selectedStatus = .home
            stopPolling()
            return
        }

        activeRequestIds = pendingIds
        for reqId in offerResults.keys {
            if !pendingIds.contains(reqId) {
                offerResults.removeValue(forKey: reqId)
            }
        }

        if offerResults.values.first(where: { $0.isAvailable }) == nil {
            selectedStatus = .searching
        }

        stopPolling()

        print("[HomeViewModel] 🟢 Starting SSE stream task group for pending request IDs: \(pendingIds)")

        pollingTask = Task {
            await withTaskGroup(of: Void.self) { group in
                group.addTask {
                    while !Task.isCancelled {
                        try? await Task.sleep(nanoseconds: 5_000_000_000) 
                        if Task.isCancelled { break }
                        await MainActor.run {
                            self.checkRequestExpiration()
                        }
                    }
                }

                for reqId in pendingIds {
                    group.addTask {
                        do {
                            print("[HomeViewModel] 📡 Listening to SSE stream for requestId: \(reqId)...")
                            let stream = self.getOfferResultUseCase.stream(requestId: reqId)
                            for try await result in stream {
                                if Task.isCancelled { break }
                                print("[HomeViewModel] 📥 Received updated OfferResult for requestId \(reqId): isAvailable=\(result.isAvailable), itemsCount=\(result.items.count), totalPrice=\(result.totalPrice)")
                                await MainActor.run {
                                    self.offerResults[reqId] = result
                                    if self.offerResults.values.contains(where: { $0.isAvailable }) {
                                        print("[HomeViewModel] 🌟 Transitioning selectedStatus -> .firstOffer")
                                        self.selectedStatus = .firstOffer
                                    } else {
                                        self.selectedStatus = .searching
                                    }
                                }
                            }
                        } catch {
                            print("[HomeViewModel] 🔴 SSE Stream error for requestId \(reqId): \(error)")
                            if case let NetworkError.validationError(message) = error, message.localizedCaseInsensitiveContains("EXPIRED") {
                                await MainActor.run {
                                    self.statusStore.clearPendingRequestId(reqId)
                                    self.offerResults.removeValue(forKey: reqId)
                                    self.activeRequestIds.removeAll { $0 == reqId }
                                    if self.activeRequestIds.isEmpty {
                                        self.selectedStatus = .home
                                    }
                                }
                            }
                        }
                    }
                }
            }
            self.pollingTask = nil
        }
    }

    private func checkRequestExpiration() {
        let allIds = statusStore.pendingRequestIds
        var changed = false
        for reqId in allIds {
            if let age = statusStore.getRequestAgeInSeconds(reqId), age > 900 {
                print("[HomeViewModel] ⏰ Request \(reqId) has expired (age: \(age)s > 900s). Clearing...")
                statusStore.clearPendingRequestId(reqId)
                offerResults.removeValue(forKey: reqId)
                changed = true
            }
        }

        if changed {
            let pendingIds = statusStore.pendingRequestIds
            activeRequestIds = pendingIds
            for reqId in offerResults.keys {
                if !pendingIds.contains(reqId) {
                    offerResults.removeValue(forKey: reqId)
                }
            }
            if pendingIds.isEmpty {
                print("[HomeViewModel] 🛑 All requests expired. Transitioning selectedStatus -> .home")
                selectedStatus = .home
                stopPolling()
            } else if offerResults.values.first(where: { $0.isAvailable }) == nil {
                selectedStatus = .searching
            }
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
