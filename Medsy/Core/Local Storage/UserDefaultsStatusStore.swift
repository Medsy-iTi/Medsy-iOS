//
//  AuthenticationStatusStore.swift
//  Medsy
//
//  Created by Ehab Salah on 17/07/2026.
//

import Foundation

protocol UserDefaultsStatusStoreProtocol {
    var isLoggedIn: Bool { get }

    func setLoggedIn(_ isLoggedIn: Bool)
}

final class UserDefaultsStatusStore: UserDefaultsStatusStoreProtocol {
    private enum Keys {
        static let isLoggedIn = "authentication.isLoggedIn"
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
}
