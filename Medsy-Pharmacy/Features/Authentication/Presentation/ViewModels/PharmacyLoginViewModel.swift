//  PharmacyLoginViewModel.swift
//  Medsy
//
//  Created by Antoneos Philip on 17/07/2026.

import Foundation
import Observation

@MainActor
@Observable
final class PharmacyLoginViewModel {
    var email = ""
    var password = ""
    var validationMessage: String?
    var isLoading = false
    var alertMessage: String?

    func submit() async -> Bool {
        guard !isLoading else { return false }
        guard !email.isEmpty, !password.isEmpty else {
            validationMessage = "auth.validation.required".localized
            return false
        }
        validationMessage = nil
        isLoading = true
        do {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            isLoading = false
            return true
        } catch {
            isLoading = false
            alertMessage = "common.error".localized
            return false
        }
    }

    func dismissError() {
        alertMessage = nil
    }
}
