//
//  NetworkError.swift
//  Medsy
//
//  Created by Ehab Salah on 01/07/2026.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    
    case badRequest                 // 400
    case unauthorized               // 401
    case notFound                   // 404
    case validationError(String)    // 422
    case serverError                // 500

    case decodingFailed
    case transportError(String)
    case unknown(Int)
    case unacceptableStatusCode(Int)
    case invalidURL
    
    var errorDescription: String? {
        switch self {
        case .badRequest:
            return "The provided data is invalid. Please try again."
        case .unauthorized:
            return "Session expired. Please log in again."
        case .notFound:
            return "The requested page or service was not found."
        case .validationError(let message):
            return message
        case .serverError:
            return "There is currently a problem with our server. Please try again later."
        case .decodingFailed:
            return "The server response could not be read. Please try again later."
        case .transportError(let message):
            return message
        case .unknown(let statusCode):
            return "An unexpected error occurred (Code: \(statusCode)). Please try again later."
        case .unacceptableStatusCode(let code):
            return "The server returned an unacceptable status code: \(code)."
        case .invalidURL:
            return "Invalid URL"
        }
    }
}
