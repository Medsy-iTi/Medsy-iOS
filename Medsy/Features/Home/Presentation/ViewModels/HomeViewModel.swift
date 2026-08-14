import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel {
    var selectedStatus: HomeSearchStatus = .home
    private(set) var offerResults: [Int: OfferResult] = [:]
    private(set) var activeRequestIds: [Int] = []
    private(set) var activeContinueMasterOrder: MasterOrderDTO?

    private let getOfferResultUseCase: GetOfferResultUseCaseProtocol
    private let offersRemoteDataSource: OffersRemoteDataSourceProtocol
    private let statusStore: UserDefaultsStatusStoreProtocol
    private var pollingTask: Task<Void, Never>?

    init(
        getOfferResultUseCase: GetOfferResultUseCaseProtocol = DIContainer.shared.resolve(GetOfferResultUseCaseProtocol.self),
        offersRemoteDataSource: OffersRemoteDataSourceProtocol = DIContainer.shared.resolve(OffersRemoteDataSourceProtocol.self),
        statusStore: UserDefaultsStatusStoreProtocol = DIContainer.shared.resolve(UserDefaultsStatusStoreProtocol.self)
    ) {
        self.getOfferResultUseCase = getOfferResultUseCase
        self.offersRemoteDataSource = offersRemoteDataSource
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

    func checkAndStartPolling() {
        Task {
            let pendingIds = self.statusStore.pendingRequestIds
            let selectedPendingIds = pendingIds.filter { id in
                UserDefaults.standard.bool(forKey: "request.isSelected.\(id)") == true &&
                UserDefaults.standard.bool(forKey: "request.isConfirmed.\(id)") == false
            }

            if !selectedPendingIds.isEmpty, let masterOrders = try? await self.offersRemoteDataSource.fetchMasterOrders(page: 0, size: 10) {
                if let resumable = masterOrders.first(where: { order in
                    selectedPendingIds.contains(order.requestId) &&
                    order.fulfillmentMethod == nil &&
                    order.orderStatus != "CONFIRMED" &&
                    order.orderStatus != "COMPLETED" &&
                    order.orderStatus != "CANCELLED" &&
                    order.orderStatus != "DELIVERED"
                }) {
                    self.activeContinueMasterOrder = resumable
                    self.selectedStatus = .continueOrder
                    return
                }
            }

            self.activeContinueMasterOrder = nil
            self.startRequestPolling()
        }
    }

    private func startRequestPolling() {
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
                        if let initialResult = try? await self.getOfferResultUseCase.execute(requestId: reqId) {
                            if Task.isCancelled { return }
                            await MainActor.run {
                                print("[HomeViewModel] 📥 Initial REST fetch for requestId \(reqId): isAvailable=\(initialResult.isAvailable), itemsCount=\(initialResult.items.count), totalPrice=\(initialResult.totalPrice)")
                                self.offerResults[reqId] = initialResult
                                if self.offerResults.values.contains(where: { $0.isAvailable }) {
                                    print("[HomeViewModel] 🌟 Initial fetch -> Transitioning selectedStatus -> .firstOffer")
                                    self.selectedStatus = .firstOffer
                                }
                            }
                        }

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
        for id in statusStore.pendingRequestIds {
            UserDefaults.standard.removeObject(forKey: "request.isSelected.\(id)")
            UserDefaults.standard.removeObject(forKey: "request.selectResult.\(id)")
        }
        statusStore.clearPendingRequestId()
        activeRequestIds = []
        offerResults = [:]
        activeContinueMasterOrder = nil
        selectedStatus = .home
    }

    func clearCompletedRequest(requestId: Int) {
        UserDefaults.standard.removeObject(forKey: "request.isSelected.\(requestId)")
        UserDefaults.standard.removeObject(forKey: "request.selectResult.\(requestId)")
        UserDefaults.standard.set(true, forKey: "request.isConfirmed.\(requestId)")
        statusStore.clearPendingRequestId(requestId)
        offerResults.removeValue(forKey: requestId)
        activeRequestIds.removeAll { $0 == requestId }
        if activeContinueMasterOrder?.requestId == requestId {
            activeContinueMasterOrder = nil
        }
        if activeRequestIds.isEmpty {
            selectedStatus = .home
            stopPolling()
        }
    }
}
