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
    var state: SignupState? { get }
    var isLoading: Bool { get }
    var alertMessage: String? { get }
    @discardableResult func submit() async -> Bool
    func dismissError()
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
    private(set) var state: SignupState?

    private let signupUseCase: SignupUseCaseProtocol

    init(signupUseCase: SignupUseCaseProtocol) {
        self.signupUseCase = signupUseCase
    }

    var isLoading: Bool {
        state == .loading
    }

    var alertMessage: String? {
        guard case .error(let message) = state else { return nil }
        return message
    }

    func submit() async -> Bool {
        guard !isLoading else { return false }

        if let validationError = AuthenticationInputValidator.validateRegistration(
            firstName: firstName,
            lastName: lastName,
            phoneNumber: phoneNumber,
            email: email,
            password: password,
            confirmedPassword: confirmedPassword,
            homeAddress: homeAddress,
            dateOfBirth: dateOfBirth
        ) {
            validationMessage = validationError.message
            return false
        }

        validationMessage = nil
        state = .loading

        let input = SignupInput(
            email: AuthenticationInputValidator.normalizedEmail(email),
            phoneNumber: phoneNumber,
            firstName: firstName,
            lastName: lastName,
            password: password,
            homeAddress: homeAddress.trimmingCharacters(in: .whitespacesAndNewlines),
            dateOfBirth: dateOfBirth
        )

        do {
            try await signupUseCase.execute(input: input)
            state = .success
            return true
        } catch is CancellationError {
            state = nil
            return false
        } catch let error as NetworkError {
            state = .error(error.errorDescription ?? "common.error".localized)
            validationMessage = error.errorDescription ?? "common.error".localized
            return false
        } catch {
            state = .error(error.localizedDescription)
            return false
        }
    }

    func dismissError() {
        guard case .error = state else { return }
        state = nil
    }
}
