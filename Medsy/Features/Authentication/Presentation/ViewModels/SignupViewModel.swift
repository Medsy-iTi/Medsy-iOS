//
//  SignupViewModel.swift
//  Medsy
//
//  Created by Ehab Salah on 16/07/2026.
//

import Observation

@MainActor
protocol SignupViewModelProtocol: AnyObject {
    var fullName: String { get set }
    var phoneNumber: String { get set }
    var email: String { get set }
    var password: String { get set }
    var confirmedPassword: String { get set }
    var hasAcceptedTerms: Bool { get set }
    var validationMessage: String? { get }
    @discardableResult func submit() -> Bool
}

@MainActor
@Observable
final class SignupViewModel: SignupViewModelProtocol {
    var fullName = ""
    var phoneNumber = ""
    var email = ""
    var password = ""
    var confirmedPassword = ""
    var hasAcceptedTerms = false
    private(set) var validationMessage: String?

    @discardableResult
    func submit() -> Bool {
        guard !fullName.isEmpty, !phoneNumber.isEmpty, !email.isEmpty,
              !password.isEmpty, !confirmedPassword.isEmpty else {
            validationMessage = "auth.validation.required".localized
            return false
        }

        validationMessage = password == confirmedPassword
            ? nil
            : "auth.validation.password_mismatch".localized
        return validationMessage == nil
    }
}
