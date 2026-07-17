//
//  NetworkRequestBuilder.swift
//  Medsy
//
//  Created by Ehab Salah on 17/07/2026.
//

import Alamofire
import Foundation

final class NetworkRequestBuilder {
    private let languageManager: LanguageManager
    private let defaultBaseURL: String

    init(
        languageManager: LanguageManager,
        defaultBaseURL: String = Constants.baseURL
    ) {
        self.languageManager = languageManager
        self.defaultBaseURL = defaultBaseURL
    }

    func makeRequest(for endpoint: ApiEndpoint, accessToken: String? = nil) throws -> URLRequest {
        let urlString = (endpoint.baseURL ?? defaultBaseURL) + endpoint.path

        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }

        var request = try URLRequest(url: url, method: endpoint.method, headers: endpoint.headers)
        request.setValue(languageManager.languageCode, forHTTPHeaderField: "Accept-Language")

        if endpoint.requiresAuthentication, let accessToken, !accessToken.isEmpty {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }

        if let queryParameters = endpoint.queryParameters {
            request = try URLEncoding.default.encode(request, with: queryParameters)
        }

        request.httpBody = endpoint.body
        return request
    }
}
