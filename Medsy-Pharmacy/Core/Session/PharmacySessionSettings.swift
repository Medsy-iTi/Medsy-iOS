//
//  PharmacySessionSettings.swift
//  Medsy
//
//  Created by Shahudaa on 22/07/2026.
//




import Foundation

final class PharmacySessionSettings: ObservableObject, PharmacyIdentityProviding {
    static let shared = PharmacySessionSettings()

    private enum Keys {
        static let currentPharmacyId = "pharmacy_current_pharmacy_id"
    }

    @Published var currentPharmacyId: Int? {
        didSet {
            if let currentPharmacyId {
                UserDefaults.standard.set(currentPharmacyId, forKey: Keys.currentPharmacyId)
            } else {
                UserDefaults.standard.removeObject(forKey: Keys.currentPharmacyId)
            }
        }
    }

    private init() {
        currentPharmacyId = UserDefaults.standard.object(forKey: Keys.currentPharmacyId) as? Int
    }

    func clear() {
        currentPharmacyId = nil
    }
}
