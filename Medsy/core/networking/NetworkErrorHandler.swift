//
//  NetworkErrorHandler.swift
//  Medsy
//
//  Created by Ehab Salah on 14/07/2026.
//

import Foundation

enum NetworkErrorHandler {
    
    static func map(error: Error, statusCode: Int?, data: Data?) -> NetworkError {
        if let apiError = apiEnvelopeError(from: data) {
            return apiError
        }

        guard let statusCode else {
            return .transportError(error.localizedDescription)
        }
        
        switch statusCode {
        case 400:
            return .badRequest
        case 401:
            return .unauthorized
        case 404:
            return .notFound
        case 422:
            guard let data,
                  let response = try? JSONDecoder().decode(APIErrorResponse.self, from: data),
                  !response.message.isEmpty else {
                return .validationError("The server rejected the data provided.")
            }
            return .validationError(response.message)
        case 500...599:
            return .serverError
        case 200...299:
            return .decodingFailed
        default:
            return .unacceptableStatusCode(statusCode)
        }
    }

    static func apiEnvelopeError(
        from data: Data?,
        decoder: JSONDecoder = JSONDecoder()
    ) -> NetworkError? {
        guard let data,
              let response = try? decoder.decode(APIErrorResponse.self, from: data),
              !response.success,
              !response.message.isEmpty else {
            return nil
        }

        return .validationError(response.message)
    }
}
