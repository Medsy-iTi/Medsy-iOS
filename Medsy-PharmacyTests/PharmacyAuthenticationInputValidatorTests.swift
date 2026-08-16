//
//  PharmacyAuthenticationInputValidatorTests.swift
//  Medsy-PharmacyTests
//
//  Created by Ehab Salah on 16/08/2026.
//

import XCTest
@testable import Medsy_Pharmacy

final class PharmacyAuthenticationInputValidatorTests: XCTestCase {
    func testWorkbookNameRules() {
        XCTAssertTrue(PharmacyAuthenticationInputValidator.isValidName("Nour"))
        XCTAssertTrue(PharmacyAuthenticationInputValidator.isValidName("عبد الرحمن"))
        XCTAssertTrue(PharmacyAuthenticationInputValidator.isValidName("Anne-Marie"))

        for value in ["", "123456", "@#$%^&*", ".", " Nour", "Nour ", "Nour😊", "Nour  Ahmed"] {
            XCTAssertFalse(
                PharmacyAuthenticationInputValidator.isValidName(value),
                "Expected invalid name: \(value)"
            )
        }

        let tooLongName = String(
            repeating: "a",
            count: PharmacyAuthenticationInputValidator.nameMaximumLength + 1
        )
        XCTAssertEqual(registrationDetailsError(firstName: tooLongName), .nameTooLong)
    }

    func testWorkbookEgyptianPhoneRules() {
        XCTAssertTrue(PharmacyAuthenticationInputValidator.isValidEgyptianMobileNumber("01012345678"))

        for value in [
            "01312345678", "01612345678", "0101234567", "010123456789",
            "01012ABC@#", "010123456.78", "01000000000", " 01012345678 "
        ] {
            XCTAssertFalse(
                PharmacyAuthenticationInputValidator.isValidEgyptianMobileNumber(value),
                "Expected invalid phone: \(value)"
            )
        }
    }

    func testWorkbookEmailRulesAndNormalization() {
        XCTAssertTrue(PharmacyAuthenticationInputValidator.isValidEmail("nour.test@example.com"))
        XCTAssertTrue(PharmacyAuthenticationInputValidator.isValidEmail(" Nour.Test@Example.COM "))
        XCTAssertEqual(
            PharmacyAuthenticationInputValidator.normalizedEmail(" Nour.Test@Example.COM "),
            "nour.test@example.com"
        )

        for value in [
            "nour.testexample.com", "nour.test@", "nour..test@example.com",
            "nour@@example.com", "nour  .test@  example.com", "nour😊@example.com"
        ] {
            XCTAssertFalse(
                PharmacyAuthenticationInputValidator.isValidEmail(value),
                "Expected invalid email: \(value)"
            )
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
    func testInvalidSubmissionKeepsEnteredValuesAndDoesNotCallAction() async {
        var submissionCount = 0
        let viewModel = makeViewModel { _ in submissionCount += 1 }
        viewModel.email = "invalid-email"

        let originalValues = [
            viewModel.firstName, viewModel.lastName, viewModel.phoneNumber,
            viewModel.email, viewModel.password, viewModel.homeAddress
        ]

        XCTAssertFalse(await viewModel.handle(.registrationSubmitted))
        XCTAssertEqual(submissionCount, 0)
        XCTAssertEqual(
            [viewModel.firstName, viewModel.lastName, viewModel.phoneNumber,
             viewModel.email, viewModel.password, viewModel.homeAddress],
            originalValues
        )
    }

    @MainActor
    func testValidSubmissionNormalizesEmailOnly() async {
        var receivedSubmission: PharmacyRegistrationSubmission?
        let viewModel = makeViewModel { receivedSubmission = $0 }
        viewModel.email = " Pharmacist@Example.COM "

        XCTAssertTrue(await viewModel.handle(.registrationSubmitted))
        XCTAssertEqual(receivedSubmission?.email, "pharmacist@example.com")
        XCTAssertEqual(receivedSubmission?.firstName, "Nour")
    }

    private func registrationDetailsError(
        firstName: String = "Nour",
        dateOfBirth: Date = Calendar.current.date(byAdding: .year, value: -18, to: Date())!
    ) -> PharmacyAuthenticationValidationError? {
        PharmacyAuthenticationInputValidator.validateRegistrationDetails(
            firstName: firstName,
            lastName: "Ahmed",
            phoneNumber: "01012345678",
            email: "nour.test@example.com",
            dateOfBirth: dateOfBirth
        )
    }

    private func accountSetupError(password: String) -> PharmacyAuthenticationValidationError? {
        PharmacyAuthenticationInputValidator.validateAccountSetup(
            password: password,
            confirmedPassword: password,
            homeAddress: "Cairo"
        )
    }

    @MainActor
    private func makeViewModel(
        registerAction: @escaping (PharmacyRegistrationSubmission) async throws -> Void
    ) -> PharmacyRegistrationViewModel {
        let viewModel = PharmacyRegistrationViewModel(registerAction: registerAction)
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
