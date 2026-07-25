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

    func setLoggedIn(_ isLoggedIn: Bool)
    func savePendingRequestId(_ requestId: Int)
    func clearPendingRequestId()
}

final class UserDefaultsStatusStore: UserDefaultsStatusStoreProtocol {
    private enum Keys {
        static let isLoggedIn = "authentication.isLoggedIn"
        static let pendingRequestId = "request.pendingRequestId"
    }

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    var isLoggedIn: Bool {
        userDefaults.bool(forKey: Keys.isLoggedIn)
    }

    func setLoggedIn(_ isLoggedIn: Bool) {
        userDefaults.set(isLoggedIn, forKey: Keys.isLoggedIn)
    }

    var pendingRequestId: Int? {
        let value = userDefaults.integer(forKey: Keys.pendingRequestId)
        return value > 0 ? value : nil
    }

    func savePendingRequestId(_ requestId: Int) {
        userDefaults.set(requestId, forKey: Keys.pendingRequestId)
    }

    func clearPendingRequestId() {
        userDefaults.removeObject(forKey: Keys.pendingRequestId)
    }
}

