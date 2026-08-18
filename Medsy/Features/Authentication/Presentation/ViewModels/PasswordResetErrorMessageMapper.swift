//
//  PasswordResetErrorMessageMapper.swift
//  Medsy
//
//  Created by Ehab Salah on 18/08/2026.
//

enum PasswordResetErrorMessageMapper {
    static func message(for error: Error) -> String {
        guard let networkError = error as? NetworkError else {
            return "auth.password_reset.error.generic".localized
        }

        switch networkError {
        case .validationError(let message):
            return message
        case .offline:
            return "common.error.offline".localized
        default:
            return "auth.password_reset.error.generic".localized
        }
    }
}
