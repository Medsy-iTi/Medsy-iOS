//
//  CartAccountScopeProvider.swift
//  Medsy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

import Foundation

enum CartPersistenceError: LocalizedError {
    case missingAccount
    case invalidPrescriptionSource

    var errorDescription: String? {
        switch self {
        case .missingAccount:
            return "Unable to identify the current cart account."
        case .invalidPrescriptionSource:
            return "Unable to read the saved prescription source."
        }
    }
}

protocol CartAccountScopeProviderProtocol {
    func currentIdentifier() throws -> String
}

final class CartAccountScopeProvider: CartAccountScopeProviderProtocol {
    private let tokenStore: TokenStoreProtocol

    init(tokenStore: TokenStoreProtocol) {
        self.tokenStore = tokenStore
    }

    func currentIdentifier() throws -> String {
        guard let token = tokenStore.accessToken(),
              let subject = subject(from: token),
              !subject.isEmpty else {
            throw CartPersistenceError.missingAccount
        }
        return subject.lowercased()
    }

    private func subject(from token: String) -> String? {
        let segments = token.split(separator: ".")
        guard segments.count > 1 else { return nil }

        var payload = String(segments[1])
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        payload += String(repeating: "=", count: (4 - payload.count % 4) % 4)

        guard let data = Data(base64Encoded: payload),
              let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return object["sub"] as? String
    }
}
