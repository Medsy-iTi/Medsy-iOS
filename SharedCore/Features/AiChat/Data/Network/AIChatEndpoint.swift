//
//  AIChatEndpoint.swift
//  SharedCore
//
//  The AI key is injected via AIChatConfiguration so this endpoint
//  compiles cleanly in both Medsy and Medsy-Pharmacy without referencing
//  any app-specific Constants struct.

import Foundation
import Alamofire

enum AIChatEndpoint: ApiEndpoint {
    case sendTextMessage(text: String)
    case sendImageMessage(imageData: Data, mimeType: String, message: String?, aiKey: String)
    case loadHistory
    case deleteHistory
    case getCartInteractions

    var path: String {
        switch self {
        case .sendTextMessage:       return "ai/chat/messages"
        case .sendImageMessage:      return "ai/chat/messages/image"
        case .loadHistory, .deleteHistory: return "ai/chat/history"
        case .getCartInteractions:   return "cart/interactions"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .sendTextMessage:    return .post
        case .sendImageMessage:   return .post
        case .loadHistory:        return .get
        case .deleteHistory:      return .delete
        case .getCartInteractions: return .get
        }
    }

    var headers: HTTPHeaders? {
        switch self {
        case .sendImageMessage(_, _, _, let aiKey):
            return ["X-AI-Api-Key": aiKey]
        default:
            return ["Content-Type": "application/json"]
        }
    }

    var body: Data? {
        switch self {
        case .sendTextMessage(let text):
            return try? JSONEncoder().encode(["message": text])
        default:
            return nil
        }
    }

    var multipartFormParts: [MultipartFormPart]? {
        switch self {
        case .sendImageMessage(let imageData, let mimeType, let message, _):
            var parts: [MultipartFormPart] = [
                MultipartFormPart(data: imageData, name: "image", fileName: "image.jpg", mimeType: mimeType)
            ]
            if let message, !message.isEmpty,
               let textData = message.data(using: .utf8) {
                parts.append(MultipartFormPart(data: textData, name: "message"))
            }
            return parts
        default:
            return nil
        }
    }

    var requiresAuthentication: Bool { true }
    var allowsResponseLogging: Bool { true }
}
