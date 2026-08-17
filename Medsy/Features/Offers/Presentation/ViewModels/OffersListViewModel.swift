//
//  OffersListViewModel.swift
//  Medsy
//
//  Created by Antoneos Philip on 25/07/2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class OffersListViewModel {
    var offers: [OfferPresentationModel] = []
    var offerResultsMap: [Int: OfferResult] = [:]
    var isLoading = false
    private let offersRemoteDataSource: OffersRemoteDataSourceProtocol?
    private let getOfferResultUseCase: GetOfferResultUseCaseProtocol?

    init(
        offersRemoteDataSource: OffersRemoteDataSourceProtocol? = nil,
        getOfferResultUseCase: GetOfferResultUseCaseProtocol? = nil
    ) {
        self.offersRemoteDataSource = offersRemoteDataSource ?? DIContainer.shared.resolve(OffersRemoteDataSourceProtocol.self)
        self.getOfferResultUseCase = getOfferResultUseCase ?? DIContainer.shared.resolve(GetOfferResultUseCaseProtocol.self)
        loadOffers()
    }

    func loadOffers() {
        guard let offersRemoteDataSource, let getOfferResultUseCase else { return }
        isLoading = true
        Task {
            defer { isLoading = false }
            async let fetchedRequests = (try? await offersRemoteDataSource.fetchRequests(page: 0, size: 5)) ?? []
            async let fetchedOrders = (try? await offersRemoteDataSource.fetchMasterOrders(page: 0, size: 5)) ?? []

            let requests = await fetchedRequests
            let orders = await fetchedOrders

            let activeSearchingRequests = requests.filter { req in
                let upperStatus = req.status.uppercased()
                let isSearchingStatus = (upperStatus == "SEARCHING" || upperStatus == "PENDING" || upperStatus == "OFFERS_READY")
                guard isSearchingStatus else { return false }
                let hasOrder = orders.contains { $0.requestId == req.id }
                return !hasOrder
            }

            var loadedOffers: [OfferPresentationModel] = []
            var resultMap: [Int: OfferResult] = [:]

            for req in activeSearchingRequests {
                if let result = try? await getOfferResultUseCase.execute(requestId: req.id), result.isAvailable {
                    resultMap[req.id] = result
                    let medNames = req.items.compactMap { $0.productName }.filter { !$0.isEmpty }.joined(separator: " + ")
                    let title = !medNames.isEmpty ? medNames : "Request #\(req.id)"
                    let availCount = result.items.filter(\.isAvailable).count
                    let totalCount = result.items.count
                    let subtitle = "\(availCount) / \(totalCount) " + "home.status.firstOffer.medsUnit".localized
                    let badge: OfferBadgeType = availCount == totalCount ? .full : .partial

                    let model = OfferPresentationModel(
                        id: "\(req.id)",
                        pharmacyName: title,
                        subtitle: subtitle,
                        price: Int(result.totalPrice),
                        badgeType: badge,
                        isBestOption: availCount == totalCount
                    )
                    loadedOffers.append(model)
                }
            }

            self.offerResultsMap = resultMap
            self.offers = loadedOffers
        }
    }

    var totalOffersCount: Int {
        offers.count
    }

    var subtitleText: String {
        String(format: "offers.list.subtitleFormat".localized, totalOffersCount)
    }
}
