//
//  PasswordResetFeatureTests.swift
//  MedsyTests
//
//  Created by Ehab Salah on 18/08/2026.
//

import XCTest
@testable import Medsy

final class PasswordResetFeatureTests: XCTestCase {
    func testPasswordResetEndpointsEncodeExactContractsAndProtectResponses() throws {
        let forgot = AuthEndpoint.forgotPassword(
            ForgotPasswordRequestDTO(input: ForgotPasswordInput(email: "user@example.com"))
        )
        XCTAssertEqual(forgot.path, "auth/forgot-password")
        XCTAssertEqual(forgot.method.rawValue, "POST")
        XCTAssertFalse(forgot.requiresAuthentication)
        XCTAssertFalse(forgot.allowsResponseLogging)
        XCTAssertEqual(try json(forgot.body), ["email": "user@example.com"])

        let verify = AuthEndpoint.verifyPasswordReset(
            VerifyPasswordResetRequestDTO(
                input: VerifyPasswordResetInput(email: "user@example.com", otpCode: "392882")
            )
        )
        XCTAssertEqual(verify.path, "auth/reset-password/verify")
        XCTAssertFalse(verify.requiresAuthentication)
        XCTAssertFalse(verify.allowsResponseLogging)
        XCTAssertEqual(
            try json(verify.body),
            ["email": "user@example.com", "otpCode": "392882"]
        )

        let reset = AuthEndpoint.resetPassword(
            ResetPasswordRequestDTO(
                input: ResetPasswordInput(resetToken: "reset-token", newPassword: "Strong@1")
            )
        )
        XCTAssertEqual(reset.path, "auth/reset-password")
        XCTAssertFalse(reset.requiresAuthentication)
        XCTAssertFalse(reset.allowsResponseLogging)
        XCTAssertEqual(
            try json(reset.body),
            ["resetToken": "reset-token", "newPassword": "Strong@1"]
        )
    }

    func testPasswordResetResponsesDecodeNullDataAndAuthorization() throws {
        let action = try JSONDecoder().decode(
            PasswordResetActionResponseDTO.self,
            from: Data(#"{"success":true,"message":"Password reset successfully","data":null}"#.utf8)
        )
        XCTAssertTrue(action.success)

        let response = try JSONDecoder().decode(
            PasswordResetVerificationResponseDTO.self,
            from: Data(
                #"{"success":true,"message":"OTP verified successfully","data":{"resetToken":"token","expiresInSeconds":600}}"#.utf8
            )
        )
        XCTAssertEqual(response.data?.toDomain(), PasswordResetAuthorization(
            resetToken: "token",
            expiresInSeconds: 600
        ))
    }

    func testDataSourcePropagatesBackendFailureMessage() async {
        let service = PasswordResetNetworkServiceSpy()
        service.response = PasswordResetActionResponseDTO(success: false, message: "Invalid email")
        let dataSource = AuthNetworkDataSource(networkService: service)

        do {
            try await dataSource.requestPasswordReset(
                request: ForgotPasswordRequestDTO(
                    input: ForgotPasswordInput(email: "user@example.com")
                )
            )
            XCTFail("Expected backend validation failure")
        } catch NetworkError.validationError(let message) {
            XCTAssertEqual(message, "Invalid email")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    @MainActor
    func testForgotPasswordNormalizesEmailAndTransitionsToSuccess() async {
        let useCase = ForgotPasswordUseCaseSpy()
        let viewModel = ForgotPasswordViewModel(initialEmail: " User@Example.COM ", useCase: useCase)

        let email = await viewModel.submit()

        XCTAssertEqual(email, "user@example.com")
        XCTAssertEqual(useCase.input, ForgotPasswordInput(email: "user@example.com"))
        XCTAssertEqual(viewModel.state, .success)
    }

    @MainActor
    func testOTPResendHasIndependentSuccessStateAndClearsCode() async {
        let verifyUseCase = VerifyPasswordResetUseCaseSpy()
        let resendUseCase = ForgotPasswordUseCaseSpy()
        let viewModel = PasswordResetOTPViewModel(
            email: "user@example.com",
            verifyUseCase: verifyUseCase,
            forgotPasswordUseCase: resendUseCase,
            resendCooldownSeconds: 0
        )
        viewModel.updateCode("123456")

        await viewModel.resend()

        XCTAssertEqual(viewModel.code, "")
        XCTAssertEqual(viewModel.state, .idle)
        XCTAssertEqual(viewModel.resendState, .success)
        XCTAssertEqual(resendUseCase.input?.email, "user@example.com")
    }

    @MainActor
    func testResetPasswordValidatesStrengthAndExpiryBeforeCallingAPI() async {
        let useCase = ResetPasswordUseCaseSpy()
        let active = ResetPasswordViewModel(
            authorization: PasswordResetAuthorization(resetToken: "token", expiresInSeconds: 600),
            useCase: useCase
        )
        active.newPassword = "weak123"
        active.confirmedPassword = "weak123"
        XCTAssertFalse(await active.submit())
        XCTAssertEqual(useCase.callCount, 0)

        active.newPassword = "Strong@1"
        active.confirmedPassword = "Strong@1"
        XCTAssertTrue(await active.submit())
        XCTAssertEqual(useCase.input?.resetToken, "token")

        let expired = ResetPasswordViewModel(
            authorization: PasswordResetAuthorization(resetToken: "expired", expiresInSeconds: 0),
            useCase: useCase
        )
        expired.newPassword = "Strong@1"
        expired.confirmedPassword = "Strong@1"
        XCTAssertFalse(await expired.submit())
        XCTAssertTrue(expired.isExpired)
        XCTAssertEqual(useCase.callCount, 1)
    }

    private func json(_ data: Data?) throws -> [String: String] {
        let data = try XCTUnwrap(data)
        return try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: String])
    }
}

private final class PasswordResetNetworkServiceSpy: NetworkServiceProtocol {
    var response: Any?

    func request<T: Decodable>(endpoint: ApiEndpoint) async throws -> T {
        guard let response = response as? T else { throw NetworkError.decodingFailed }
        return response
    }

    func requestData(endpoint: ApiEndpoint) async throws -> Data { Data() }
}

private final class ForgotPasswordUseCaseSpy: ForgotPasswordUseCaseProtocol {
    var input: ForgotPasswordInput?
    var error: Error?

    func execute(input: ForgotPasswordInput) async throws {
        self.input = input
        if let error { throw error }
    }
}

private final class VerifyPasswordResetUseCaseSpy: VerifyPasswordResetUseCaseProtocol {
    var input: VerifyPasswordResetInput?
    var authorization = PasswordResetAuthorization(resetToken: "token", expiresInSeconds: 600)

    func execute(input: VerifyPasswordResetInput) async throws -> PasswordResetAuthorization {
        self.input = input
        return authorization
    }
}

private final class ResetPasswordUseCaseSpy: ResetPasswordUseCaseProtocol {
    var callCount = 0
    var input: ResetPasswordInput?

    func execute(input: ResetPasswordInput) async throws {
        callCount += 1
        self.input = input
    }
}
