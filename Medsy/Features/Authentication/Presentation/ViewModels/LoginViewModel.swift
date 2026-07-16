//
//  LoginViewModel.swift
//  Medsy
//
//  Created by Ehab Salah on 16/07/2026.
//

import Observation

@MainActor
protocol LoginViewModelProtocol: AnyObject {
    var phoneNumber: String { get set }
    var password: String { get set }
    var validationMessage: String? { get }
    @discardableResult func submit() -> Bool
}

@MainActor
@Observable
final class LoginViewModel: LoginViewModelProtocol {
    var phoneNumber = ""
    var password = ""
    private(set) var validationMessage: String?

    @discardableResult
    func submit() -> Bool {
        validationMessage = phoneNumber.isEmpty || password.isEmpty
            ? "auth.validation.required".localized
            : nil
        return validationMessage == nil
    }
}
