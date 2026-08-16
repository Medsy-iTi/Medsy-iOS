//
//  AuthenticationInputValidatorTests.swift
//  MedsyTests
//
//  Created by Ehab Salah on 16/08/2026.
//

import XCTest
@testable import Medsy

final class AuthenticationInputValidatorTests: XCTestCase {
    func testWorkbookNameRules() {
        XCTAssertTrue(AuthenticationInputValidator.isValidName("Nour"))
        XCTAssertTrue(AuthenticationInputValidator.isValidName("عبد الرحمن"))
        XCTAssertTrue(AuthenticationInputValidator.isValidName("Anne-Marie"))

        for value in ["", "123456", "@#$%^&*", ".", " Nour", "Nour ", "Nour😊", "Nour  Ahmed"] {
            XCTAssertFalse(AuthenticationInputValidator.isValidName(value), "Expected invalid name: \(value)")
        }

        let tooLongName = String(repeating: "a", count: AuthenticationInputValidator.nameMaximumLength + 1)
        XCTAssertEqual(
            registrationDetailsError(firstName: tooLongName),
            .nameTooLong
        )
    }

    func testWorkbookEgyptianPhoneRules() {
        XCTAssertTrue(AuthenticationInputValidator.isValidEgyptianMobileNumber("01012345678"))
        XCTAssertTrue(AuthenticationInputValidator.isValidEgyptianMobileNumber("01112345678"))
        XCTAssertTrue(AuthenticationInputValidator.isValidEgyptianMobileNumber("01212345678"))
        XCTAssertTrue(AuthenticationInputValidator.isValidEgyptianMobileNumber("01512345678"))

        for value in [
            "01312345678", "01612345678", "0101234567", "010123456789",
            "01012ABC@#", "010123456.78", "01000000000", " 01012345678 "
        ] {
            XCTAssertFalse(
                AuthenticationInputValidator.isValidEgyptianMobileNumber(value),
                "Expected invalid phone: \(value)"
            )
        }
    }

    func testWorkbookEmailRulesAndNormalization() {
        XCTAssertTrue(AuthenticationInputValidator.isValidEmail("nour.test@example.com"))
        XCTAssertTrue(AuthenticationInputValidator.isValidEmail(" Nour.Test@Example.COM "))
        XCTAssertEqual(
            AuthenticationInputValidator.normalizedEmail(" Nour.Test@Example.COM "),
            "nour.test@example.com"
        )

        for value in [
            "nour.testexample.com", "nour.test@", "nour..test@example.com",
            "nour@@example.com", "nour  .test@  example.com", "nour😊@example.com"
        ] {
            XCTAssertFalse(AuthenticationInputValidator.isValidEmail(value), "Expected invalid email: \(value)")
        }
    }

    func testWorkbookPasswordRules() {
        XCTAssertNil(accountSetupError(password: "Joe@12"))
        XCTAssertNil(accountSetupError(password: "Joe@12345678900"))

        XCTAssertEqual(accountSetupError(password: "Nour@"), .passwordLength)
        XCTAssertEqual(accountSetupError(password: "Yousseffff@Aliii"), .passwordLength)
        XCTAssertEqual(accountSetupError(password: "Nour @123456"), .passwordWhitespace)
        XCTAssertEqual(accountSetupError(password: "        "), .passwordWhitespace)
        XCTAssertEqual(accountSetupError(password: "000000"), .weakPassword)
        XCTAssertEqual(accountSetupError(password: "@@@@@@"), .weakPassword)
        XCTAssertEqual(accountSetupError(password: "Nour@123😊"), .weakPassword)
    }

    func testRegistrationRejectsFutureDateOfBirth() {
        let futureDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        XCTAssertEqual(registrationDetailsError(dateOfBirth: futureDate), .futureDateOfBirth)
    }

    @MainActor
    func testInvalidSubmissionKeepsEnteredValuesAndDoesNotCallUseCase() async {
        let useCase = AuthenticationValidationSignupUseCaseSpy()
        let viewModel = makeViewModel(useCase: useCase)
        viewModel.email = "invalid-email"

        let originalValues = [
            viewModel.firstName, viewModel.lastName, viewModel.phoneNumber,
            viewModel.email, viewModel.password, viewModel.homeAddress
        ]

        let submitResult = await viewModel.submit()
        XCTAssertFalse(submitResult)
        XCTAssertEqual(useCase.callCount, 0)
        XCTAssertEqual(
            [viewModel.firstName, viewModel.lastName, viewModel.phoneNumber,
             viewModel.email, viewModel.password, viewModel.homeAddress],
            originalValues
        )
    }

    @MainActor
    func testValidSubmissionNormalizesEmailOnly() async {
        let useCase = AuthenticationValidationSignupUseCaseSpy()
        let viewModel = makeViewModel(useCase: useCase)
        viewModel.email = " User@Example.COM "

        let submitResult = await viewModel.submit()
        XCTAssertTrue(submitResult)
        XCTAssertEqual(useCase.receivedInput?.email, "user@example.com")
        XCTAssertEqual(useCase.receivedInput?.firstName, "Nour")
    }

    private func registrationDetailsError(
        firstName: String = "Nour",
        dateOfBirth: Date = Calendar.current.date(byAdding: .year, value: -18, to: Date())!
    ) -> AuthenticationValidationError? {
        AuthenticationInputValidator.validateRegistrationDetails(
            firstName: firstName,
            lastName: "Ahmed",
            phoneNumber: "01012345678",
            email: "nour.test@example.com",
            dateOfBirth: dateOfBirth
        )
    }

    private func accountSetupError(password: String) -> AuthenticationValidationError? {
        AuthenticationInputValidator.validateAccountSetup(
            password: password,
            confirmedPassword: password,
            homeAddress: "Cairo"
        )
    }

    @MainActor
    private func makeViewModel(useCase: AuthenticationValidationSignupUseCaseSpy) -> SignupViewModel {
        let viewModel = SignupViewModel(signupUseCase: useCase)
        viewModel.firstName = "Nour"
        viewModel.lastName = "Ahmed"
        viewModel.phoneNumber = "01012345678"
        viewModel.email = "nour.test@example.com"
        viewModel.password = "Nour@123"
        viewModel.confirmedPassword = "Nour@123"
        viewModel.homeAddress = "Cairo"
        return viewModel
    }
}

private final class AuthenticationValidationSignupUseCaseSpy: SignupUseCaseProtocol {
    private(set) var callCount = 0
    private(set) var receivedInput: SignupInput?

    func execute(input: SignupInput) async throws {
        callCount += 1
        receivedInput = input
    }
}
