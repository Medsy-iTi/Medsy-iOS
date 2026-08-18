//
//  PharmacyPasswordResetErrorMessageMapper.swift
//  Medsy-Pharmacy
//
//  Created by Ehab Salah on 18/08/2026.
//

enum PharmacyPasswordResetErrorMessageMapper {
    static func message(for error: Error) -> String {
        guard let networkError = error as? NetworkError else {
            return "pharmacy.auth.password_reset.error.generic".localized
        }

        switch networkError {
        case .validationError(let message):
            return message
        case .offline:
            return "common.error.offline".localized
        default:
            return "pharmacy.auth.password_reset.error.generic".localized
        }
    }
}
