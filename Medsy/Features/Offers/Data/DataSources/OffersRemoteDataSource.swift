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
        let rawData = try await networkService.requestData(
            endpoint: OffersEndpoint.getResult(requestId: requestId)
        )
        if let parsed = parseStreamResponse(rawData) {
            return parsed
        }
        if let response = try? JSONDecoder().decode(GetOfferResultResponseDTO.self, from: rawData),
           response.success, let data = response.data {
            return data
        }
        if let direct = try? JSONDecoder().decode(OfferResultResponseDTO.self, from: rawData) {
            return direct
        }
        throw NetworkError.decodingFailed
    }

    private func parseStreamResponse(_ data: Data) -> OfferResultResponseDTO? {
        guard let text = String(data: data, encoding: .utf8) else { return nil }
        let lines = text.components(separatedBy: .newlines)
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("data:") {
                let jsonString = String(trimmed.dropFirst(5)).trimmingCharacters(in: .whitespaces)
                if let jsonData = jsonString.data(using: .utf8) {
                    if let dto = try? JSONDecoder().decode(OfferResultResponseDTO.self, from: jsonData) {
                        return dto
                    }
                    if let env = try? JSONDecoder().decode(GetOfferResultResponseDTO.self, from: jsonData),
                       let dto = env.data {
                        return dto
                    }
                }
            }
        }
        return nil
    }

    func confirmOffer(requestId: Int, selectedRequestItemIds: [Int]) async throws -> ConfirmOfferResponseDTO {
        let body = ConfirmOfferRequestDTO(selectedRequestItemIds: selectedRequestItemIds)
        let response: ConfirmOfferResponseDTOContainer = try await networkService.request(
            endpoint: OffersEndpoint.confirmOffer(requestId: requestId, body: body)
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
