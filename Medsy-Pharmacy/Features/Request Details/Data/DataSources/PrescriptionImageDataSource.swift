//
//  PrescriptionImageDataSource.swift
//  Medsy-Pharmacy
//

import UIKit

final class PrescriptionImageDataSource {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func fetchImage(urlString: String) async throws -> UIImage {
        let path: String
        if let range = urlString.range(of: "uploads/") {
            path = String(urlString[range.lowerBound...])
        } else {
            path = urlString
        }

        let data = try await networkService.requestData(
            endpoint: PrescriptionImageEndpoint.fetchImage(path: path)
        )

        guard let image = UIImage(data: data) else {
            throw NetworkError.decodingFailed
        }
        return image
    }
}
