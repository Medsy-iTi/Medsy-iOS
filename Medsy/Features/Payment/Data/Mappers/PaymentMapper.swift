//
//  PaymentMapper.swift
//  Medsy
//
//  Created by Ahmed Elkady on 11/08/2026.
//

import Foundation

enum PaymentMapper {
    static func map(_ dto: MasterOrderPaymentDTO) -> MasterOrderPayment {
        MasterOrderPayment(
            id: dto.id,
            paymentMethod: MasterOrderPaymentMethod(rawValue: dto.paymentMethod.uppercased()) ?? .unknown,
            paymentStatus: MasterOrderPaymentStatus(rawValue: dto.paymentStatus.uppercased()) ?? .unknown,
            orderStatus: MasterOrderStatus(rawValue: dto.orderStatus.uppercased()) ?? .unknown,
            paymentExpiresAt: parseBackendDate(dto.paymentExpiresAt),
            paidAt: parseBackendDate(dto.paidAt)
        )
    }

    static func map(_ dto: PaymentIntentDTO) -> PaymentIntent {
        PaymentIntent(
            id: dto.paymentIntentId,
            clientSecret: dto.clientSecret
        )
    }

    private static func parseBackendDate(_ value: String?) -> Date? {
        guard let value, !value.isEmpty else { return nil }

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFormatter.date(from: value) {
            return date
        }
        isoFormatter.formatOptions = [.withInternetDateTime]
        if let date = isoFormatter.date(from: value) {
            return date
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = .current

        for format in [
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSSS",
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSS",
            "yyyy-MM-dd'T'HH:mm:ss.SSS",
            "yyyy-MM-dd'T'HH:mm:ss"
        ] {
            formatter.dateFormat = format
            if let date = formatter.date(from: value) {
                return date
            }
        }
        return nil
    }
}
