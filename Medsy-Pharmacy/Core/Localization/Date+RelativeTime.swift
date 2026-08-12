//
//  Date+RelativeTime.swift
//  Medsy-Pharmacy
//

import Foundation

extension Date {
    /// Returns a localized relative time string (e.g. "47 minutes ago", "منذ 47 دقيقة").
    var relativeTimeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.locale = Locale.current
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
