//
//  OffersRemoteDataSource.swift
//  Medsy
//
//  Created by Antoneos Philip on 25/07/2026.
//

import Foundation

protocol OffersRemoteDataSourceProtocol {
    func getOfferResult(requestId: Int) async throws -> OfferResultResponseDTO
    func confirmOffer(requestId: Int, selections: [ConfirmOfferSelection]) async throws -> ConfirmOfferDataDTO
}

final class OffersRemoteDataSource: OffersRemoteDataSourceProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func getOfferResult(requestId: Int) async throws -> OfferResultResponseDTO {
        let response: GetOfferResultResponseDTO = try await networkService.request(
            endpoint: OffersEndpoint.getResult(requestId: requestId)
        )
        guard response.success else {
            throw NetworkError.validationError(response.message)
        }
        guard let data = response.data else {
            throw NetworkError.decodingFailed
        }
        return data
    }

    func confirmOffer(requestId: Int, selections: [ConfirmOfferSelection]) async throws -> ConfirmOfferDataDTO {
        let selectionBody = ConfirmOfferRequestDTO(
            selectedItems: selections.map {
                ConfirmOfferSelectionDTO(
                    requestItemId: $0.requestItemId,
                    productId: $0.productId
                )
            }
        )
        let selectionResponse: ConfirmOfferResponseDTOContainer = try await networkService.request(
            endpoint: OffersEndpoint.selectOffer(requestId: requestId, body: selectionBody)
        )
        let selection = try unwrap(selectionResponse)

        let fulfillmentResponse: FulfillmentConfirmationResponseDTOContainer = try await networkService.request(
            endpoint: OffersEndpoint.confirmFulfillment(
                requestId: requestId,
                body: FulfillmentConfirmationRequestDTO(fulfillmentMethod: "DELIVERY")
            )
        )
        let fulfillment = try unwrap(fulfillmentResponse)

        return ConfirmOfferDataDTO(
            selection: selection,
            fulfillment: fulfillment,
            selectedRequestItemIds: selections.map(\.requestItemId)
        )
    }

    private func unwrap<T>(_ response: APIResponseDTO<T>) throws -> T {
        guard response.success else {
            throw NetworkError.validationError(response.message)
        }
        guard let data = response.data else {
            throw NetworkError.decodingFailed
        }
        return data
    }
}
