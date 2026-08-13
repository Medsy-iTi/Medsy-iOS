//
//  AccountScopeProvider.swift
//  Medsy
//
//  Created by Ehab Salah on 13/08/2026.
//

import Foundation

enum AccountScopeError: LocalizedError {
    case missingAccount

    var errorDescription: String? {
        "Unable to identify the current account."
    }
}

protocol AccountScopeProviderProtocol {
    func currentIdentifier() throws -> String
}

final class AccountScopeProvider: AccountScopeProviderProtocol {
    private let tokenStore: TokenStoreProtocol

    init(tokenStore: TokenStoreProtocol) {
        self.tokenStore = tokenStore
    }

    func currentIdentifier() throws -> String {
        guard let token = tokenStore.accessToken(),
              let subject = subject(from: token),
              !subject.isEmpty else {
            throw AccountScopeError.missingAccount
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
