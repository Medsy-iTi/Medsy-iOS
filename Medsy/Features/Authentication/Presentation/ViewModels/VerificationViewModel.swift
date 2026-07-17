//
//  VerificationViewModel.swift
//  Medsy
//
//  Created by Ehab Salah on 17/07/2026.

import Observation

@MainActor
@Observable
final class VerificationViewModel {
    var code = ""
    private(set) var validationMessage: String?

    func updateCode(_ value: String) {
        code = String(value.filter(\.isNumber).prefix(6))
        validationMessage = nil
    }

    func clearValidationMessage() {
        validationMessage = nil
    }

    @discardableResult
    func submit() -> Bool {
        guard code.count == 6 else {
            validationMessage = "auth.verification.invalid_code".localized
            return false
        }

        validationMessage = nil
        return true
    }
}
