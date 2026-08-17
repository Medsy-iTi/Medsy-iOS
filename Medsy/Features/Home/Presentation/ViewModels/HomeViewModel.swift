import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
final class HomeViewModel {
    var selectedStatus: HomeSearchStatus = .home
    var isRefreshing: Bool = false
    private(set) var offerResults: [Int: OfferResult] = [:]
    private(set) var activeRequestIds: [Int] = []
    private(set) var activeSearchRequestsList: [CompleteRequestResponseDTO] = []
    private(set) var activeContinueMasterOrder: MasterOrderDTO?

    private let getOfferResultUseCase: GetOfferResultUseCaseProtocol
    private let offersRemoteDataSource: OffersRemoteDataSourceProtocol
    private var pollingTask: Task<Void, Never>?
    private var isCheckingPolling = false
    private var isStreamConnected: [Int: Bool] = [:]

    init(
        getOfferResultUseCase: GetOfferResultUseCaseProtocol = DIContainer.shared.resolve(GetOfferResultUseCaseProtocol.self),
        offersRemoteDataSource: OffersRemoteDataSourceProtocol = DIContainer.shared.resolve(OffersRemoteDataSourceProtocol.self)
    ) {
        self.getOfferResultUseCase = getOfferResultUseCase
        self.offersRemoteDataSource = offersRemoteDataSource
    }

    var firstAvailableOfferResult: OfferResult? {
        offerResults.values.first(where: { $0.isAvailable })
    }

    var firstAvailableRequestId: Int? {
        offerResults.first(where: { $0.value.isAvailable })?.key ?? activeRequestIds.first
    }

    var activeRequestCreatedAt: Date? {
        if let firstReqId = firstAvailableRequestId,
           let req = activeSearchRequestsList.first(where: { $0.id == firstReqId }) {
            return req.createdAt.toBackendDate()
        }
        return activeSearchRequestsList.first?.createdAt.toBackendDate()
    }

    var availableOffersCount: Int {
        offerResults.values.filter(\.isAvailable).count
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

    func refresh() async {
        isRefreshing = true
        defer { isRefreshing = false }
        isCheckingPolling = false
        stopPolling()
        await performCheckAndStartPolling(forceRestartStream: true)
    }

    func checkAndStartPolling(forceRestartStream: Bool = false) {
        if !forceRestartStream && isCheckingPolling { return }
        Task {
            await performCheckAndStartPolling(forceRestartStream: forceRestartStream)
        }
    }

    private func performCheckAndStartPolling(forceRestartStream: Bool) async {
        if !forceRestartStream && isCheckingPolling { return }
        isCheckingPolling = true
        defer { self.isCheckingPolling = false }

        let useCase = self.getOfferResultUseCase
        let existingIds = self.activeRequestIds

        // 1. Fetch current REST offers for known active requests immediately in parallel
        if !existingIds.isEmpty {
            await withTaskGroup(of: (Int, OfferResult?).self) { group in
                for reqId in existingIds {
                    group.addTask {
                        let res = try? await useCase.execute(requestId: reqId)
                        return (reqId, res)
                    }
                }
                for await (reqId, maybeResult) in group {
                    if let result = maybeResult {
                        self.applyOfferResult(result, for: reqId)
                    }
                }
            }
        }

        // 2. Fetch requests and orders list in parallel
        async let fetchedRequests = (try? await self.offersRemoteDataSource.fetchRequests(page: 0, size: 10)) ?? []
        async let fetchedOrders = (try? await self.offersRemoteDataSource.fetchMasterOrders(page: 0, size: 10)) ?? []

        let recentRequests = await fetchedRequests
        let recentOrders = await fetchedOrders

        let activeSearchRequests = recentRequests.filter { req in
            let upperStatus = req.status.uppercased()
            let isSearchingStatus = (upperStatus == "SEARCHING" || upperStatus == "PENDING" || upperStatus == "OFFERS_READY")
            guard isSearchingStatus else { return false }

            if let createdDate = req.createdAt.toBackendDate() {
                let ageInSeconds = Date().timeIntervalSince(createdDate)
                guard ageInSeconds < 900 else { return false }
            }

            let hasMasterOrder = recentOrders.contains { $0.requestId == req.id }
            return !hasMasterOrder
        }

        let resumableOrder = recentOrders.first(where: { order in
            let upperStatus = order.orderStatus.uppercased()
            let isCardAwaitingPayment = (order.paymentMethod?.uppercased() == "CARD" && upperStatus == "PENDING")
            if isCardAwaitingPayment { return true }
            let isFulfillmentAwaiting = (upperStatus == "PENDING" && order.fulfillmentMethod == nil)
            if isFulfillmentAwaiting {
                return true
            }
            return false
        })

        let newIds = activeSearchRequests.map(\.id)
        if let resumable = resumableOrder {
            self.stopPolling()
            self.activeRequestIds = []
            self.offerResults = [:]
            self.activeSearchRequestsList = []
            self.activeContinueMasterOrder = resumable
            self.selectedStatus = .continueOrder
        } else if !activeSearchRequests.isEmpty {
            self.activeContinueMasterOrder = nil
            self.activeSearchRequestsList = activeSearchRequests
            self.offerResults = self.offerResults.filter { newIds.contains($0.key) }
            let idsChanged = self.activeRequestIds != newIds
            self.activeRequestIds = newIds

            // Fetch current REST offer snapshots immediately for all active requests in parallel
            await withTaskGroup(of: (Int, OfferResult?).self) { group in
                for req in activeSearchRequests {
                    let reqId = req.id
                    group.addTask {
                        let res = try? await useCase.execute(requestId: reqId)
                        return (reqId, res)
                    }
                }
                for await (reqId, maybeResult) in group {
                    if let result = maybeResult {
                        self.applyOfferResult(result, for: reqId)
                    }
                }
            }

            // Start or restart stream when forced, when IDs changed, or when task was nil
            if forceRestartStream || idsChanged || self.pollingTask == nil {
                self.startRequestsStreaming(for: activeSearchRequests)
            }
        } else if !recentRequests.isEmpty || !recentOrders.isEmpty {
            // Only clear to home if requests and orders returned successfully and are genuinely empty
            self.stopPolling()
            self.activeRequestIds = []
            self.offerResults = [:]
            self.activeSearchRequestsList = []
            self.activeContinueMasterOrder = nil
            self.selectedStatus = .home
        }
    }

    private func applyOfferResult(_ result: OfferResult, for reqId: Int) {
        self.offerResults[reqId] = result
        let availableCount = self.offerResults.values.filter(\.isAvailable).count
        if availableCount > 1 {
            self.selectedStatus = .multipleOffers
        } else if availableCount == 1 {
            self.selectedStatus = .firstOffer
        } else {
            self.selectedStatus = .searching
        }
    }

    private func startRequestsStreaming(for requests: [CompleteRequestResponseDTO]) {
        stopPolling()

        let requestIds = requests.map(\.id)
        print("[HomeViewModel] 🟢 Starting resilient SSE stream and 3s fallback task group for request IDs: \(requestIds)")
        let useCase = self.getOfferResultUseCase

        pollingTask = Task {
            await withTaskGroup(of: Void.self) { group in
                // 1. Expiration monitor task (15 minutes limit)
                group.addTask {
                    while !Task.isCancelled {
                        try? await Task.sleep(nanoseconds: 1_000_000_000)
                        if Task.isCancelled { break }
                        var anyExpired = false
                        for req in requests {
                            if let created = req.createdAt.toBackendDate() {
                                let age = Date().timeIntervalSince(created)
                                if age >= 900 {
                                    anyExpired = true
                                    break
                                }
                            }
                        }
                        if anyExpired {
                            await MainActor.run {
                                self.checkAndStartPolling(forceRestartStream: false)
                            }
                            break
                        }
                    }
                }

                // 2. Resilient SSE Stream tasks + 3. 3s Disconnection Fallback for each request ID
                for req in requests {
                    let reqId = req.id
                    let createdAt = req.createdAt.toBackendDate()

                    // Real-time SSE Stream Task
                    group.addTask {
                        var retryDelayNanoseconds: UInt64 = 1_000_000_000

                        while !Task.isCancelled {
                            let isStillActive = await MainActor.run {
                                self.activeRequestIds.contains(reqId)
                            }
                            guard isStillActive else {
                                print("[HomeViewModel] 🛑 Request \(reqId) is no longer in activeRequestIds, stopping stream loop.")
                                await MainActor.run {
                                    _ = self.isStreamConnected.removeValue(forKey: reqId)
                                }
                                break
                            }

                            if let created = createdAt, Date().timeIntervalSince(created) >= 900 {
                                print("[HomeViewModel] ⏱️ Request \(reqId) expired (>900s), stopping stream.")
                                await MainActor.run {
                                    self.activeRequestIds.removeAll { $0 == reqId }
                                    self.offerResults.removeValue(forKey: reqId)
                                    _ = self.isStreamConnected.removeValue(forKey: reqId)
                                    self.checkAndStartPolling(forceRestartStream: false)
                                }
                                break
                            }

                            do {
                                print("[HomeViewModel] 📡 Listening to SSE stream for requestId: \(reqId)...")
                                let stream = useCase.stream(requestId: reqId)
                                for try await result in stream {
                                    if Task.isCancelled { break }
                                    await MainActor.run {
                                        self.isStreamConnected[reqId] = true
                                        if !result.items.isEmpty {
                                            print("[HomeViewModel] 📥 [SSE] Received updated OfferResult for requestId \(reqId): isAvailable=\(result.isAvailable), itemsCount=\(result.items.count), totalPrice=\(result.totalPrice)")
                                            self.applyOfferResult(result, for: reqId)
                                        }
                                    }
                                    // Reset retry delay on valid connection/data reception
                                    retryDelayNanoseconds = 1_000_000_000
                                }
                            } catch {
                                if !Task.isCancelled {
                                    print("[HomeViewModel] 🔴 SSE Stream error for requestId \(reqId): \(error)")
                                }
                            }

                            await MainActor.run {
                                self.isStreamConnected[reqId] = false
                            }

                            if Task.isCancelled { break }

                            // If offline or disconnected, try getting fresh REST result without breaking the retry loop on errors
                            if let freshResult = try? await useCase.execute(requestId: reqId) {
                                await MainActor.run {
                                    self.applyOfferResult(freshResult, for: reqId)
                                }
                            }

                            print("[HomeViewModel] 🔄 Reconnecting SSE stream for requestId \(reqId) in \(Double(retryDelayNanoseconds) / 1_000_000_000.0)s...")
                            try? await Task.sleep(nanoseconds: retryDelayNanoseconds)
                            retryDelayNanoseconds = min(retryDelayNanoseconds * 2, 8_000_000_000)
                        }
                    }

                    // 3-second REST Fallback Task: ONLY polls when SSE Stream is down or disconnected!
                    group.addTask {
                        while !Task.isCancelled {
                            try? await Task.sleep(nanoseconds: 3_000_000_000)
                            if Task.isCancelled { break }

                            let isStillActive = await MainActor.run {
                                self.activeRequestIds.contains(reqId)
                            }
                            guard isStillActive else { break }

                            if let created = createdAt, Date().timeIntervalSince(created) >= 900 { break }

                            let isConnected = await MainActor.run {
                                self.isStreamConnected[reqId] ?? false
                            }

                            // If stream is active and connected, do NOT poll!
                            if isConnected {
                                continue
                            }

                            // Stream is disconnected: execute 3s REST fallback
                            do {
                                let fallbackResult = try await useCase.execute(requestId: reqId)
                                print("[HomeViewModel] ⏱️ [3s Fallback (Stream Disconnected)] Fetched OfferResult for requestId \(reqId): isAvailable=\(fallbackResult.isAvailable), items=\(fallbackResult.items.count)")
                                await MainActor.run {
                                    self.applyOfferResult(fallbackResult, for: reqId)
                                }
                            } catch {
                                print("[HomeViewModel] ⚠️ [3s Fallback] Request \(reqId) error: \(error)")
                            }
                        }
                    }
                }
            }
            self.pollingTask = nil
        }
    }

    func handleScenePhaseChange(to newPhase: ScenePhase) {
        switch newPhase {
        case .active:
            print("[HomeViewModel] 📱 scenePhase -> .active: refreshing data and ensuring active stream")
            checkAndStartPolling(forceRestartStream: true)
        case .inactive, .background:
            break
        @unknown default:
            break
        }
    }

    func handleScreenCaptureChange(isCaptured: Bool) {
        print("[HomeViewModel] 🎥 Screen capture state changed: isCaptured=\(isCaptured)")
        if !activeRequestIds.isEmpty {
            checkAndStartPolling(forceRestartStream: false)
        }
    }

    func handleAppActive() {
        print("[HomeViewModel] 📲 App active / willEnterForeground triggered: refreshing data and ensuring active stream")
        checkAndStartPolling(forceRestartStream: true)
    }

    func handleAppBackground() {
        print("[HomeViewModel] 💤 App background")
    }

    func stopPolling() {
        pollingTask?.cancel()
        pollingTask = nil
        isStreamConnected.removeAll()
    }

    func clearActiveRequest() {
        stopPolling()
        activeRequestIds = []
        offerResults = [:]
        activeSearchRequestsList = []
        activeContinueMasterOrder = nil
        selectedStatus = .home
    }

    func clearCompletedRequest(requestId: Int) {
        offerResults.removeValue(forKey: requestId)
        activeRequestIds.removeAll { $0 == requestId }
        activeSearchRequestsList.removeAll { $0.id == requestId }
        if activeContinueMasterOrder?.requestId == requestId {
            activeContinueMasterOrder = nil
        }
        if activeRequestIds.isEmpty {
            selectedStatus = .home
            stopPolling()
        }
        checkAndStartPolling()
    }
}

