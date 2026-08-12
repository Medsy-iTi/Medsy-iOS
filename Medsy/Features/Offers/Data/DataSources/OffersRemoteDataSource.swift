//
//  OffersRemoteDataSource.swift
//  Medsy
//
//  Created by Antoneos Philip on 25/07/2026.
//

import Foundation

protocol OffersRemoteDataSourceProtocol {
    func getOfferResult(requestId: Int) async throws -> OfferResultResponseDTO
    func confirmOffer(requestId: Int, selectedRequestItemIds: [Int]) async throws -> ConfirmOfferResponseDTO
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

    func confirmOffer(requestId: Int, selectedRequestItemIds: [Int]) async throws -> ConfirmOfferResponseDTO {
        let selectBody = ConfirmOfferRequestDTO(selectedRequestItemIds: selectedRequestItemIds)
        let selectResponse: APIResponseDTO<SelectPharmacyResponseDTO> = try await networkService.request(
            endpoint: OffersEndpoint.selectPharmacy(requestId: requestId, body: selectBody)
        )
        guard selectResponse.success else {
            throw NetworkError.validationError(selectResponse.message)
        }

        let response: ConfirmOfferResponseDTOContainer = try await networkService.request(
            endpoint: OffersEndpoint.confirmOffer(requestId: requestId)
        )
        guard response.success else {
            throw NetworkError.validationError(response.message)
        }
        guard let data = response.data else {
            throw NetworkError.decodingFailed
        }
        return data
    }
}
