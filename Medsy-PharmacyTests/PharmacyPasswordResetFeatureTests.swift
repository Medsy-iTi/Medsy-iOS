//
//  PharmacyPasswordResetFeatureTests.swift
//  Medsy-PharmacyTests
//
//  Created by Ehab Salah on 18/08/2026.
//

import XCTest
@testable import Medsy_Pharmacy

final class PharmacyPasswordResetFeatureTests: XCTestCase {
    func testPasswordResetEndpointsEncodeExactContractsAndProtectResponses() throws {
        let forgot = PharmacyAuthenticationEndpoint.forgotPassword(
            PharmacyForgotPasswordRequestDTO(
                input: PharmacyForgotPasswordInput(email: "pharmacist@example.com")
            )
        )
        XCTAssertEqual(forgot.path, "auth/forgot-password")
        XCTAssertEqual(forgot.method.rawValue, "POST")
        XCTAssertFalse(forgot.requiresAuthentication)
        XCTAssertFalse(forgot.allowsResponseLogging)
        XCTAssertEqual(try json(forgot.body), ["email": "pharmacist@example.com"])

        let verify = PharmacyAuthenticationEndpoint.verifyPasswordReset(
            PharmacyVerifyPasswordResetRequestDTO(
                input: PharmacyVerifyPasswordResetInput(
                    email: "pharmacist@example.com",
                    otpCode: "392882"
                )
            )
        )
        XCTAssertEqual(verify.path, "auth/reset-password/verify")
        XCTAssertFalse(verify.allowsResponseLogging)
        XCTAssertEqual(
            try json(verify.body),
            ["email": "pharmacist@example.com", "otpCode": "392882"]
        )

        let reset = PharmacyAuthenticationEndpoint.resetPassword(
            PharmacyResetPasswordRequestDTO(
                input: PharmacyResetPasswordInput(
                    resetToken: "reset-token",
                    newPassword: "Strong@1"
                )
            )
        )
        XCTAssertEqual(reset.path, "auth/reset-password")
        XCTAssertFalse(reset.allowsResponseLogging)
        XCTAssertEqual(
            try json(reset.body),
            ["resetToken": "reset-token", "newPassword": "Strong@1"]
        )
    }

    func testPasswordResetResponsesDecodeNullDataAndAuthorization() throws {
        let action = try JSONDecoder().decode(
            PharmacyPasswordResetActionResponseDTO.self,
            from: Data(#"{"success":true,"message":"Password reset successfully","data":null}"#.utf8)
        )
        XCTAssertTrue(action.success)

        let response = try JSONDecoder().decode(
            PharmacyPasswordResetVerificationResponseDTO.self,
            from: Data(
                #"{"success":true,"message":"OTP verified successfully","data":{"resetToken":"token","expiresInSeconds":600}}"#.utf8
            )
        )
        XCTAssertEqual(response.data?.toDomain(), PharmacyPasswordResetAuthorization(
            resetToken: "token",
            expiresInSeconds: 600
        ))
    }

    @MainActor
    func testForgotPasswordNormalizesEmailAndTransitionsToSuccess() async {
        var receivedInput: PharmacyForgotPasswordInput?
        let viewModel = PharmacyForgotPasswordViewModel(
            initialEmail: " Pharmacist@Example.COM ",
            requestAction: { receivedInput = $0 }
        )

        let email = await viewModel.submit()

        XCTAssertEqual(email, "pharmacist@example.com")
        XCTAssertEqual(receivedInput, PharmacyForgotPasswordInput(email: "pharmacist@example.com"))
        XCTAssertEqual(viewModel.state, .success)
    }

    @MainActor
    func testOTPResendHasIndependentSuccessStateAndClearsCode() async {
        var resendCount = 0
        let viewModel = PharmacyPasswordResetOTPViewModel(
            email: "pharmacist@example.com",
            verifyAction: { _ in
                PharmacyPasswordResetAuthorization(resetToken: "token", expiresInSeconds: 600)
            },
            resendAction: { _ in resendCount += 1 },
            resendCooldownSeconds: 0
        )
        viewModel.updateCode("123456")

        await viewModel.resend()

        XCTAssertEqual(viewModel.code, "")
        XCTAssertEqual(viewModel.state, .idle)
        XCTAssertEqual(viewModel.resendState, .success)
        XCTAssertEqual(resendCount, 1)
    }

    @MainActor
    func testResetPasswordValidatesStrengthAndExpiryBeforeCallingAPI() async {
        var receivedInput: PharmacyResetPasswordInput?
        let active = PharmacyResetPasswordViewModel(
            authorization: PharmacyPasswordResetAuthorization(
                resetToken: "token",
                expiresInSeconds: 600
            ),
            resetAction: { receivedInput = $0 }
        )
        active.newPassword = "weak123"
        active.confirmedPassword = "weak123"
        XCTAssertFalse(await active.submit())
        XCTAssertNil(receivedInput)

        active.newPassword = "Strong@1"
        active.confirmedPassword = "Strong@1"
        XCTAssertTrue(await active.submit())
        XCTAssertEqual(receivedInput?.resetToken, "token")

        var expiredCallCount = 0
        let expired = PharmacyResetPasswordViewModel(
            authorization: PharmacyPasswordResetAuthorization(
                resetToken: "expired",
                expiresInSeconds: 0
            ),
            resetAction: { _ in expiredCallCount += 1 }
        )
        expired.newPassword = "Strong@1"
        expired.confirmedPassword = "Strong@1"
        XCTAssertFalse(await expired.submit())
        XCTAssertTrue(expired.isExpired)
        XCTAssertEqual(expiredCallCount, 0)
    }

    private func json(_ data: Data?) throws -> [String: String] {
        let data = try XCTUnwrap(data)
        return try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: String])
    }
}
