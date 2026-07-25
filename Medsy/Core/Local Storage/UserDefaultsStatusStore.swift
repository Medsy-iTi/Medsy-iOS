//
//  AuthenticationStatusStore.swift
//  Medsy
//
//  Created by Ehab Salah on 17/07/2026.
//

import Foundation

protocol UserDefaultsStatusStoreProtocol {
    var isLoggedIn: Bool { get }
    var pendingRequestId: Int? { get }
    var pendingRequestIds: [Int] { get }

    func setLoggedIn(_ isLoggedIn: Bool)
    func savePendingRequestId(_ requestId: Int)
    func clearPendingRequestId()
    func clearPendingRequestId(_ requestId: Int)
}

final class UserDefaultsStatusStore: UserDefaultsStatusStoreProtocol {
    private enum Keys {
        static let isLoggedIn = "authentication.isLoggedIn"
        static let pendingRequestId = "request.pendingRequestId"
        static let pendingRequestIds = "request.pendingRequestIds"
    }

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        migrateIfNeeded()
    }

    var isLoggedIn: Bool {
        userDefaults.bool(forKey: Keys.isLoggedIn)
    }

    func setLoggedIn(_ isLoggedIn: Bool) {
        userDefaults.set(isLoggedIn, forKey: Keys.isLoggedIn)
    }

    var pendingRequestId: Int? {
        pendingRequestIds.first
    }

    var pendingRequestIds: [Int] {
        userDefaults.array(forKey: Keys.pendingRequestIds) as? [Int] ?? []
    }

    func savePendingRequestId(_ requestId: Int) {
        var ids = pendingRequestIds
        if !ids.contains(requestId) {
            ids.append(requestId)
        }
        userDefaults.set(ids, forKey: Keys.pendingRequestIds)
    }

    func clearPendingRequestId() {
        userDefaults.removeObject(forKey: Keys.pendingRequestIds)
        userDefaults.removeObject(forKey: Keys.pendingRequestId)
    }

    func clearPendingRequestId(_ requestId: Int) {
        var ids = pendingRequestIds
        ids.removeAll { $0 == requestId }
        if ids.isEmpty {
            userDefaults.removeObject(forKey: Keys.pendingRequestIds)
        } else {
            userDefaults.set(ids, forKey: Keys.pendingRequestIds)
        }
    }

    private func migrateIfNeeded() {
        let oldValue = userDefaults.integer(forKey: Keys.pendingRequestId)
        if oldValue > 0 {
            savePendingRequestId(oldValue)
            userDefaults.removeObject(forKey: Keys.pendingRequestId)
        }
    }
}

