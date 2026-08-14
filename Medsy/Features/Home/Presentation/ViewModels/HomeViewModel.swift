import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel {
    var selectedStatus: HomeSearchStatus = .home
    private(set) var offerResults: [Int: OfferResult] = [:]
    private(set) var activeRequestIds: [Int] = []
    private(set) var activeSearchRequestsList: [CompleteRequestResponseDTO] = []
    private(set) var activeContinueMasterOrder: MasterOrderDTO?

    private let getOfferResultUseCase: GetOfferResultUseCaseProtocol
    private let offersRemoteDataSource: OffersRemoteDataSourceProtocol
    private var pollingTask: Task<Void, Never>?

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

    func checkAndStartPolling() {
        Task {
            async let fetchedRequests = (try? await self.offersRemoteDataSource.fetchRequests(page: 0, size: 3)) ?? []
            async let fetchedOrders = (try? await self.offersRemoteDataSource.fetchMasterOrders(page: 0, size: 3)) ?? []

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
                let availableCount = self.offerResults.values.filter(\.isAvailable).count
                if availableCount > 1 {
                    self.selectedStatus = .multipleOffers
                } else if availableCount == 1 {
                    self.selectedStatus = .firstOffer
                } else {
                    self.selectedStatus = .searching
                }
                if idsChanged || self.pollingTask == nil {
                    self.startRequestsStreaming(for: activeSearchRequests)
                }
            } else {
                self.stopPolling()
                self.activeRequestIds = []
                self.offerResults = [:]
                self.activeSearchRequestsList = []
                self.activeContinueMasterOrder = nil
                self.selectedStatus = .home
            }
        }
    }

    private func startRequestsStreaming(for requests: [CompleteRequestResponseDTO]) {
        stopPolling()

        let requestIds = requests.map(\.id)
        print("[HomeViewModel] 🟢 Starting SSE stream task group for request IDs: \(requestIds)")
        let useCase = self.getOfferResultUseCase

        pollingTask = Task {
            await withTaskGroup(of: Void.self) { group in
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
                                self.checkAndStartPolling()
                            }
                            break
                        }
                    }
                }

                for req in requests {
                    let reqId = req.id
                    group.addTask {
                        do {
                            print("[HomeViewModel] 📡 Listening to SSE stream for requestId: \(reqId)...")
                            let stream = useCase.stream(requestId: reqId)
                            for try await result in stream {
                                if Task.isCancelled { break }
                                print("[HomeViewModel] 📥 Received updated OfferResult for requestId \(reqId): isAvailable=\(result.isAvailable), itemsCount=\(result.items.count), totalPrice=\(result.totalPrice)")
                                await MainActor.run {
                                    self.offerResults[reqId] = result
                                    let availableCount = self.offerResults.values.filter(\.isAvailable).count
                                    if availableCount > 1 {
                                        print("[HomeViewModel] 🌟 Transitioning selectedStatus -> .multipleOffers")
                                        self.selectedStatus = .multipleOffers
                                    } else if availableCount == 1 {
                                        print("[HomeViewModel] 🌟 Transitioning selectedStatus -> .firstOffer")
                                        self.selectedStatus = .firstOffer
                                    } else {
                                        self.selectedStatus = .searching
                                    }
                                }
                            }
                        } catch {
                            if !Task.isCancelled {
                                print("[HomeViewModel] 🔴 SSE Stream error for requestId \(reqId): \(error)")
                            }
                        }
                    }
                }
            }
            self.pollingTask = nil
        }
    }

    func stopPolling() {
        pollingTask?.cancel()
        pollingTask = nil
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
