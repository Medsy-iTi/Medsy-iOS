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
        static let isOnDuty = "pharmacist.duty.status"
    }

    private let defaults: UserDefaults

    @Published var currentPharmacyId: Int? {
        didSet {
            if let currentPharmacyId {
                defaults.set(currentPharmacyId, forKey: Keys.currentPharmacyId)
            } else {
                defaults.removeObject(forKey: Keys.currentPharmacyId)
            }
        }
    }

    @Published private(set) var pharmacyName: String?
    @Published private(set) var pharmacyAddress: String?
    @Published private(set) var isOnDuty: Bool

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        currentPharmacyId = defaults.object(forKey: Keys.currentPharmacyId) as? Int
        isOnDuty = defaults.bool(forKey: Keys.isOnDuty)
    }

    func updatePharmacy(id: Int?, name: String?, address: String?) {
        currentPharmacyId = id
        pharmacyName = Self.nonEmpty(name)
        pharmacyAddress = Self.nonEmpty(address)
    }

    func updateDutyStatus(_ isOnDuty: Bool) {
        self.isOnDuty = isOnDuty
        defaults.set(isOnDuty, forKey: Keys.isOnDuty)
    }

    func clear() {
        currentPharmacyId = nil
        pharmacyName = nil
        pharmacyAddress = nil
        isOnDuty = false
        defaults.removeObject(forKey: Keys.isOnDuty)
    }

    private static func nonEmpty(_ value: String?) -> String? {
        guard let value = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              !value.isEmpty else {
            return nil
        }
        return value
    }
}
