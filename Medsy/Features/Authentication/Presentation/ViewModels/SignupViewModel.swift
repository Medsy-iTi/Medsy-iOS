//
//  SignupViewModel.swift
//  Medsy
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
    func submit()
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

    func submit() {
        guard !fullName.isEmpty, !phoneNumber.isEmpty, !email.isEmpty,
              !password.isEmpty, !confirmedPassword.isEmpty else {
            validationMessage = "auth.validation.required".localized
            return
        }

        validationMessage = password == confirmedPassword
            ? nil
            : "auth.validation.password_mismatch".localized
    }
}
