//
//  LoginViewModel.swift
//  Medsy
//

import Observation

@MainActor
protocol LoginViewModelProtocol: AnyObject {
    var phoneNumber: String { get set }
    var password: String { get set }
    var validationMessage: String? { get }
    func submit()
}

@MainActor
@Observable
final class LoginViewModel: LoginViewModelProtocol {
    var phoneNumber = ""
    var password = ""
    private(set) var validationMessage: String?

    func submit() {
        validationMessage = phoneNumber.isEmpty || password.isEmpty
            ? "auth.validation.required".localized
            : nil
    }
}
