//
//  NetworkSevice.swift
//  Medsy
//
//  Created by Ehab Salah on 14/07/2026.
//

import Foundation
import Alamofire


final class NetworkService: NetworkServiceProtocol {


    private let languageManager: LanguageManager


    init(languageManager: LanguageManager) {
        self.languageManager = languageManager
    }


    private var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        return decoder
    }


    func request<T: Decodable>(endpoint: ApiEndpoint) async throws -> T {

        let urlString = (endpoint.baseURL ?? Constants.baseURL) + endpoint.path

        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }

        var urlRequest = try URLRequest(url: url, method: endpoint.method, headers: endpoint.headers)

        urlRequest.setValue(languageManager.languageCode, forHTTPHeaderField: "Accept-Language")

        if let queryParameters = endpoint.queryParameters {
            urlRequest = try URLEncoding.default.encode(urlRequest, with: queryParameters)
        }

        if let body = endpoint.body {
            urlRequest.httpBody = body
        }

        let response = await AF.request(urlRequest)
            .validate()
            .serializingDecodable(T.self, decoder: decoder)
            .response

        if let data = response.data {
            let method = endpoint.method.rawValue
            let status = response.response?.statusCode ?? 0
            print("[Network Log] \(method) \(urlString) [Status: \(status)] [Lang: \(languageManager.languageCode)]")
            print("Response JSON:\n\(JsonHelper.prettyJSON(data))\n-----------------------------")
        }

        if let apiError = Self.apiEnvelopeError(from: response.data, decoder: decoder) {
            throw apiError
        }

        switch response.result {
        case .success(let data):
            return data

        case .failure(let alamofireError):
            throw NetworkErrorHandler.map(
                error: alamofireError,
                statusCode: response.response?.statusCode,
                data: response.data
            )
        }
    }

    static func apiEnvelopeError(
        from data: Data?,
        decoder: JSONDecoder = JSONDecoder()
    ) -> NetworkError? {
        guard let data,
              let envelope = try? decoder.decode(APIStatusEnvelope.self, from: data),
              !envelope.success else {
            return nil
        }

        return .validationError(envelope.message)
    }
}

private struct APIStatusEnvelope: Decodable {
    let success: Bool
    let message: String
}
