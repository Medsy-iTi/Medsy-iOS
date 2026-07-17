//  PharmacyTokenStore.swift
//  Medsy
//
//  Created by Antoneos Philip on 17/07/2026.

import Foundation
import Security

final class PharmacyKeychainTokenStore: TokenStoreProtocol {
    private let service: String
    private let accessTokenAccount = "access-token"
    private let refreshTokenAccount = "refresh-token"

    init(service: String = "com.medsy-pharmacy.authentication") {
        self.service = service
    }

    func accessToken() -> String? {
        value(for: accessTokenAccount)
    }

    func refreshToken() -> String? {
        value(for: refreshTokenAccount)
    }

    func save(accessToken: String, refreshToken: String) throws {
        try save(accessToken, for: accessTokenAccount)
        try save(refreshToken, for: refreshTokenAccount)
    }

    func clearTokens() throws {
        try deleteValue(for: accessTokenAccount)
        try deleteValue(for: refreshTokenAccount)
    }

    private func value(for account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess,
              let data = item as? Data else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    private func save(_ value: String, for account: String) throws {
        let data = Data(value.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        let attributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]
        let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

        if updateStatus == errSecItemNotFound {
            let addStatus = SecItemAdd((query.merging(attributes) { _, new in new }) as CFDictionary, nil)
            guard addStatus == errSecSuccess else { throw KeychainError(status: addStatus) }
        } else if updateStatus != errSecSuccess {
            throw KeychainError(status: updateStatus)
        }
    }

    private func deleteValue(for account: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError(status: status)
        }
    }
}

private struct KeychainError: LocalizedError {
    let status: OSStatus

    var errorDescription: String? {
        "Unable to securely update the current session."
    }
}
