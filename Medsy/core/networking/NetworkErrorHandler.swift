//
//  NetworkErrorHandler.swift
//  Medsy
//
//  Created by Ehab Salah on 14/07/2026.
//

import Foundation

enum NetworkErrorHandler {
    
    static func map(error: Error,statusCode: Int?,data: Data?) -> NetworkError {
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
            let message = apiErrorMessage(from: data)
            ?? "The server rejected the data provided."
            return .validationError(message)
        case 500...599:
            return .serverError
        case 200...299:
            return .decodingFailed
        default:
            return .unacceptableStatusCode(statusCode)
        }
    }
    
    /// Supports common API error shapes without depending on a specific backend.
    /// Examples: { "message": "..." }, { "error": "..." }, and
    /// { "errors": { "email": ["is invalid"] } }.
    private static func apiErrorMessage(from data: Data?) -> String? {
        guard let data,let object = try? JSONSerialization.jsonObject(with: data) else {
            return nil
        }
        
        if let dictionary = object as? [String: Any] {
            for key in ["message", "error", "detail"] {
                if let message = dictionary[key] as? String, !message.isEmpty {
                    return message
                }
            }
            
            if let errors = dictionary["errors"] {
                return flattenedErrorMessage(from: errors)
            }
        }
        
        return flattenedErrorMessage(from: object)
    }
    
    private static func flattenedErrorMessage(from value: Any) -> String? {
        if let message = value as? String {
            return message.isEmpty ? nil : message
        }
        
        if let messages = value as? [Any] {
            let parts = messages.compactMap(flattenedErrorMessage(from:))
            return parts.isEmpty ? nil : parts.joined(separator: ", ")
        }
        
        if let fields = value as? [String: Any] {
            let parts = fields.sorted { $0.key < $1.key }.compactMap { key, value in
                flattenedErrorMessage(from: value).map { "\(key): \($0)" }
            }
            return parts.isEmpty ? nil : parts.joined(separator: "\n")
        }
        
        return nil
    }
}
