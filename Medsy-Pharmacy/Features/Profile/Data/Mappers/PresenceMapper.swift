//
//  PresenceMapper.swift
//  Medsy
//
//  Created by Shahudaa on 22/07/2026.
//


import Foundation

enum PresenceMapper {
    static func toDomain(_ dto: PresenceStatusDTO) -> PresenceStatus {
        PresenceStatus(
            isOnDuty: dto.onDuty,
            lastHeartbeatAt: parseDate(dto.lastHeartbeatAt)
        )
    }


    private static func parseDate(_ value: String) -> Date? {
        if let date = plainFormatter.date(from: value) {
            return date
        }
        if let date = fractionalFormatter.date(from: value) {
            return date
        }

        guard
            let dotIndex = value.firstIndex(of: "."),
            let zIndex = value.firstIndex(of: "Z"),
            value.index(after: dotIndex) < zIndex
        else { return nil }

        let fraction = value[value.index(after: dotIndex)..<zIndex].prefix(3)
        let truncated = value[value.startIndex..<dotIndex] + "." + fraction + "Z"
        return fractionalFormatter.date(from: String(truncated))
    }

    private static let plainFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    private static let fractionalFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
}
