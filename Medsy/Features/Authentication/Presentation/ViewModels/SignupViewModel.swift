//
//  SignupViewModel.swift
//  Medsy
//
//  Created by Ehab Salah on 16/07/2026.
//

import Foundation
import Observation

@MainActor
protocol SignupViewModelProtocol: AnyObject {
    var firstName: String { get set }
    var lastName: String { get set }
    var phoneNumber: String { get set }
    var email: String { get set }
    var password: String { get set }
    var confirmedPassword: String { get set }
    var homeAddress: String { get set }
    var dateOfBirth: Date { get set }
    var hasAcceptedTerms: Bool { get set }
    var validationMessage: String? { get }
    @discardableResult func submit() -> Bool
}

@MainActor
@Observable
final class SignupViewModel: SignupViewModelProtocol {
    var firstName = ""
    var lastName = ""
    var phoneNumber = ""
    var email = ""
    var password = ""
    var confirmedPassword = ""
    var homeAddress = ""
    var dateOfBirth = Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()
    var hasAcceptedTerms = false
    private(set) var validationMessage: String?

    @discardableResult
    func submit() -> Bool {
        guard !firstName.isEmpty, !lastName.isEmpty, !phoneNumber.isEmpty,
              !email.isEmpty, !password.isEmpty, !confirmedPassword.isEmpty,
              !homeAddress.isEmpty else {
            validationMessage = "auth.validation.required".localized
            return false
        }

        validationMessage = password == confirmedPassword
            ? nil
            : "auth.validation.password_mismatch".localized
        return validationMessage == nil
    }
}
