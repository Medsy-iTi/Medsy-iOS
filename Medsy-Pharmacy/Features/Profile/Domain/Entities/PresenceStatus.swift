//
//  PresenceStatus.swift
//  Medsy-Pharmacy
//

import Foundation

/// Domain entity representing the authenticated pharmacist's on-duty presence state.
struct PresenceStatus {
    /// Whether the pharmacist is currently on duty and eligible to receive requests.
    let onDuty: Bool
    /// The timestamp of the last heartbeat sent to the server, if available.
    let lastHeartbeatAt: Date?
}
