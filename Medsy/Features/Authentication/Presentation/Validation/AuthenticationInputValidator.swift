//
//  AuthenticationInputValidator.swift
//  Medsy
//
//  Created by Ehab Salah on 16/08/2026.
//

import Foundation

enum AuthenticationValidationError: Equatable {
    case firstNameRequired
    case lastNameRequired
    case phoneRequired
    case emailRequired
    case passwordRequired
    case confirmedPasswordRequired
    case homeAddressRequired
    case invalidFirstName
    case invalidLastName
    case nameTooLong
    case invalidPhone
    case invalidEmail
    case passwordLength
    case passwordWhitespace
    case weakPassword
    case passwordMismatch
    case futureDateOfBirth

    var message: String {
        switch self {
        case .firstNameRequired:
            "auth.validation.first_name_required".localized
        case .lastNameRequired:
            "auth.validation.last_name_required".localized
        case .phoneRequired:
            "auth.validation.phone_required".localized
        case .emailRequired:
            "auth.validation.email_required".localized
        case .passwordRequired:
            "auth.validation.password_required".localized
        case .confirmedPasswordRequired:
            "auth.validation.confirm_password_required".localized
        case .homeAddressRequired:
            "auth.validation.home_address_required".localized
        case .invalidFirstName:
            "auth.validation.first_name".localized
        case .invalidLastName:
            "auth.validation.last_name".localized
        case .nameTooLong:
            "auth.validation.name_length".localized
        case .invalidPhone:
            "auth.validation.phone".localized
        case .invalidEmail:
            "auth.validation.email".localized
        case .passwordLength:
            "auth.validation.password_length".localized
        case .passwordWhitespace:
            "auth.validation.password_whitespace".localized
        case .weakPassword:
            "auth.validation.password_strength".localized
        case .passwordMismatch:
            "auth.validation.password_mismatch".localized
        case .futureDateOfBirth:
            "auth.validation.date_of_birth".localized
        }
    }
}

enum AuthenticationInputValidator {
    static let nameMaximumLength = 50
    static let phoneLength = 11
    static let emailMaximumLength = 254
    static let passwordMinimumLength = 6
    static let passwordMaximumLength = 15

    static func validateRegistration(
        firstName: String,
        lastName: String,
        phoneNumber: String,
        email: String,
        password: String,
        confirmedPassword: String,
        homeAddress: String,
        dateOfBirth: Date,
        now: Date = Date()
    ) -> AuthenticationValidationError? {
        if let detailsError = validateRegistrationDetails(
            firstName: firstName,
            lastName: lastName,
            phoneNumber: phoneNumber,
            email: email,
            dateOfBirth: dateOfBirth,
            now: now
        ) {
            return detailsError
        }

        return validateAccountSetup(
            password: password,
            confirmedPassword: confirmedPassword,
            homeAddress: homeAddress
        )
    }

    static func validateRegistrationDetails(
        firstName: String,
        lastName: String,
        phoneNumber: String,
        email: String,
        dateOfBirth: Date,
        now: Date = Date()
    ) -> AuthenticationValidationError? {
        if firstName.isEmpty { return .firstNameRequired }
        if lastName.isEmpty { return .lastNameRequired }
        if phoneNumber.isEmpty { return .phoneRequired }
        if normalizedEmail(email).isEmpty { return .emailRequired }

        if firstName.count > nameMaximumLength || lastName.count > nameMaximumLength {
            return .nameTooLong
        }
        if !isValidName(firstName) { return .invalidFirstName }
        if !isValidName(lastName) { return .invalidLastName }
        if !isValidEgyptianMobileNumber(phoneNumber) { return .invalidPhone }
        if !isValidEmail(email) { return .invalidEmail }

        let calendar = Calendar.current
        if calendar.startOfDay(for: dateOfBirth) > calendar.startOfDay(for: now) {
            return .futureDateOfBirth
        }

        return nil
    }

    static func validateAccountSetup(
        password: String,
        confirmedPassword: String,
        homeAddress: String
    ) -> AuthenticationValidationError? {
        if let passwordError = validatePasswordReset(
            password: password,
            confirmedPassword: confirmedPassword
        ) {
            return passwordError
        }
        if homeAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .homeAddressRequired
        }

        return nil
    }

    static func validatePasswordReset(
        password: String,
        confirmedPassword: String
    ) -> AuthenticationValidationError? {
        if password.isEmpty { return .passwordRequired }
        if confirmedPassword.isEmpty { return .confirmedPasswordRequired }

        if !(passwordMinimumLength...passwordMaximumLength).contains(password.count) {
            return .passwordLength
        }
        if password.unicodeScalars.contains(where: { $0.properties.isWhitespace }) {
            return .passwordWhitespace
        }
        if !isStrongPassword(password) { return .weakPassword }
        if password != confirmedPassword { return .passwordMismatch }

        return nil
    }

    static func validateLogin(email: String, password: String) -> AuthenticationValidationError? {
        if normalizedEmail(email).isEmpty { return .emailRequired }
        if password.isEmpty { return .passwordRequired }
        if !isValidEmail(email) { return .invalidEmail }
        return nil
    }

    static func normalizedEmail(_ email: String) -> String {
        email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    static func isValidName(_ name: String) -> Bool {
        guard !name.isEmpty,
              name == name.trimmingCharacters(in: .whitespacesAndNewlines),
              name.first?.isLetter == true,
              name.last?.isLetter == true else {
            return false
        }

        let allowedSeparators: Set<Character> = [" ", "-", "'", "’"]
        var previousWasSeparator = false

        for character in name {
            if character.isLetter {
                previousWasSeparator = false
            } else if allowedSeparators.contains(character), !previousWasSeparator {
                previousWasSeparator = true
            } else {
                return false
            }
        }

        return true
    }

    static func isValidEgyptianMobileNumber(_ phoneNumber: String) -> Bool {
        guard phoneNumber.count == phoneLength,
              phoneNumber.unicodeScalars.allSatisfy({ (48...57).contains($0.value) }),
              ["010", "011", "012", "015"].contains(String(phoneNumber.prefix(3))) else {
            return false
        }

        return !phoneNumber.dropFirst(3).allSatisfy { $0 == "0" }
    }

    static func isValidEmail(_ email: String) -> Bool {
        let email = normalizedEmail(email)
        guard email.count <= emailMaximumLength,
              !email.contains(where: { $0.isWhitespace }) else {
            return false
        }

        let parts = email.split(separator: "@", omittingEmptySubsequences: false)
        guard parts.count == 2 else { return false }

        let localPart = String(parts[0])
        let domain = String(parts[1])
        guard !localPart.isEmpty,
              localPart.count <= 64,
              localPart.first != ".",
              localPart.last != ".",
              !localPart.contains(".."),
              localPart.range(
                of: "^[A-Z0-9!#$%&'*+/=?^_`{|}~.-]+$",
                options: [.regularExpression, .caseInsensitive]
              ) != nil else {
            return false
        }

        let labels = domain.split(separator: ".", omittingEmptySubsequences: false)
        guard labels.count >= 2,
              labels.last?.count ?? 0 >= 2 else {
            return false
        }

        return labels.allSatisfy { label in
            guard !label.isEmpty,
                  label.first != "-",
                  label.last != "-" else {
                return false
            }
            return label.unicodeScalars.allSatisfy { scalar in
                (48...57).contains(scalar.value)
                    || (65...90).contains(scalar.value)
                    || (97...122).contains(scalar.value)
                    || scalar.value == 45
            }
        }
    }

    static func isStrongPassword(_ password: String) -> Bool {
        guard password.unicodeScalars.allSatisfy({ (33...126).contains($0.value) }) else {
            return false
        }

        var hasLowercase = false
        var hasUppercase = false
        var hasDigit = false
        var hasSpecialCharacter = false

        for scalar in password.unicodeScalars {
            switch scalar.value {
            case 48...57:
                hasDigit = true
            case 65...90:
                hasUppercase = true
            case 97...122:
                hasLowercase = true
            default:
                hasSpecialCharacter = true
            }
        }

        return hasLowercase && hasUppercase && hasDigit && hasSpecialCharacter
    }
}
