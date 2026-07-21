//
//  ProfileDateMapper.swift
//  Medsy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

import Foundation

enum ProfileDateMapper {
    static func date(_ value: String) -> Date? {
        formatter().date(from: value)
    }

    static func string(_ value: Date) -> String {
        formatter().string(from: value)
    }

    private static func formatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
}
