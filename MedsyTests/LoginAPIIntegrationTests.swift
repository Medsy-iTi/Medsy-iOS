//
//  LoginAPIIntegrationTests.swift
//  MedsyTests
//
//  Created by Ehab Salah on 17/07/2026.
//

import XCTest
@testable import Medsy

final class LoginAPIIntegrationTests: XCTestCase {
    func testLoginRequestEncodesExactAPIContract() throws {
        let input = LoginInput(email: "user@example.com", password: "password")
        let request = LoginRequestDTO(input: input)
        let data = try JSONEncoder().encode(request)
        let json = try XCTUnwrap(
            JSONSerialization.jsonObject(with: data) as? [String: String]
        )

        XCTAssertEqual(json, [
            "email": "user@example.com",
            "password": "password"
        ])
    }

    func testAuthEndpointUsesLoginPathAndPostMethod() {
        let endpoint = AuthEndpoint.login(
            LoginRequestDTO(input: LoginInput(email: "user@example.com", password: "password"))
        )

        XCTAssertEqual(endpoint.path, "auth/login")
        XCTAssertEqual(endpoint.method, .post)
        XCTAssertNotNil(endpoint.body)
    }

    func testNetworkDataSourceUsesNetworkServiceForLogin() async throws {
        let networkService = LoginNetworkServiceSpy()
        networkService.response = AuthSessionResponseDTO(
            success: true,
            message: "Logged in",
            data: makeSessionDTO()
        )
        let dataSource = AuthNetworkDataSource(networkService: networkService)

        let session = try await dataSource.login(
            request: LoginRequestDTO(input: LoginInput(email: "user@example.com", password: "password"))
        )

        XCTAssertEqual(networkService.capturedEndpoint?.path, "auth/login")
        XCTAssertEqual(networkService.capturedEndpoint?.method, .post)
        XCTAssertEqual(session.accessToken, "access")
    }

    func testRepositoryAndUseCaseForwardLoginInputAndStoreTokens() async throws {
        let dataSource = LoginDataSourceSpy(session: makeSession())
        let repository = AuthRepository(networkDataSource: dataSource)
        let tokenStore = LoginTokenStoreSpy()
        let useCase = LoginUseCase(repository: repository, tokenStore: tokenStore)
        let input = LoginInput(email: "user@example.com", password: "password")

        let result = try await useCase.execute(input: input)

        XCTAssertEqual(dataSource.loginRequest, LoginRequestDTO(input: input))
        XCTAssertEqual(result, makeSession())
        XCTAssertEqual(tokenStore.access, "access")
        XCTAssertEqual(tokenStore.refresh, "refresh")
    }

    @MainActor
    func testLoginViewModelLocalValidationDoesNotCallUseCase() async {
        let useCase = LoginUseCaseSpy()
        let viewModel = LoginViewModel(loginUseCase: useCase)

        let succeeded = await viewModel.submit()

        XCTAssertFalse(succeeded)
        XCTAssertEqual(useCase.callCount, 0)
        XCTAssertEqual(viewModel.validationMessage, "auth.validation.required".localized)
        XCTAssertNil(viewModel.state)
    }

    @MainActor
    func testLoginViewModelTransitionsToSuccessAndBlocksDuplicates() async {
        let useCase = LoginUseCaseSpy()
        useCase.onExecute = { try? await Task.sleep(for: .milliseconds(100)) }
        let viewModel = LoginViewModel(loginUseCase: useCase)
        viewModel.email = "user@example.com"
        viewModel.password = "password"

        async let firstSubmission = viewModel.submit()
        await Task.yield()
        let duplicateSubmission = await viewModel.submit()
        let firstSucceeded = await firstSubmission

        XCTAssertTrue(firstSucceeded)
        XCTAssertFalse(duplicateSubmission)
        XCTAssertEqual(useCase.callCount, 1)
        XCTAssertEqual(viewModel.state, .success)
    }

    @MainActor
    func testLoginViewModelExposesAPIErrorForValidationAndAlert() async {
        let useCase = LoginUseCaseSpy()
        useCase.error = NetworkError.validationError("Invalid credentials")
        let viewModel = LoginViewModel(loginUseCase: useCase)
        viewModel.email = "user@example.com"
        viewModel.password = "password"

        let succeeded = await viewModel.submit()

        XCTAssertFalse(succeeded)
        XCTAssertEqual(viewModel.state, .error("Invalid credentials"))
        XCTAssertEqual(viewModel.validationMessage, "Invalid credentials")
        XCTAssertEqual(viewModel.alertMessage, "Invalid credentials")

        viewModel.dismissError()
        XCTAssertNil(viewModel.state)
        XCTAssertNil(viewModel.alertMessage)
    }

    private func makeSession() -> AuthenticatedSession {
        AuthenticatedSession(
            accessToken: "access",
            refreshToken: "refresh",
            user: .init(
                id: 1,
                email: "user@example.com",
                firstName: "Ehab",
                lastName: "Salah",
                role: "CUSTOMER",
                homeAddress: "Cairo",
                dateOfBirth: "1995-04-23"
            )
        )
    }

    private func makeSessionDTO() -> AuthSessionDTO {
        AuthSessionDTO(
            accessToken: "access",
            refreshToken: "refresh",
            user: .init(
                id: 1,
                email: "user@example.com",
                firstName: "Ehab",
                lastName: "Salah",
                role: "CUSTOMER",
                homeAddress: "Cairo",
                dob: "1995-04-23"
            )
        )
    }
}

private enum LoginTestError: Error {
    case invalidResponseType
}

private final class LoginNetworkServiceSpy: NetworkServiceProtocol {
    var capturedEndpoint: ApiEndpoint?
    var response: Any?

    func request<T: Decodable>(endpoint: ApiEndpoint) async throws -> T {
        capturedEndpoint = endpoint
        guard let response = response as? T else {
            throw LoginTestError.invalidResponseType
        }
        return response
    }
}

private final class LoginDataSourceSpy: AuthNetworkDataSourceProtocol {
    var loginRequest: LoginRequestDTO?
    let session: AuthenticatedSession

    init(session: AuthenticatedSession) {
        self.session = session
    }

    func login(request: LoginRequestDTO) async throws -> AuthSessionDTO {
        loginRequest = request
        return AuthSessionDTO(
            accessToken: session.accessToken,
            refreshToken: session.refreshToken,
            user: .init(
                id: session.user.id,
                email: session.user.email,
                firstName: session.user.firstName,
                lastName: session.user.lastName,
                role: session.user.role,
                homeAddress: session.user.homeAddress,
                dob: session.user.dateOfBirth
            )
        )
    }

    func register(request: SignupRequestDTO) async throws {}

    func verify(request: VerificationRequestDTO) async throws -> AuthSessionDTO {
        throw LoginTestError.invalidResponseType
    }

    func logout(request: LogoutRequestDTO) async throws {}
}

private final class LoginTokenStoreSpy: TokenStoreProtocol {
    var access: String?
    var refresh: String?

    func accessToken() -> String? { access }
    func refreshToken() -> String? { refresh }
    func save(accessToken: String, refreshToken: String) throws {
        access = accessToken
        refresh = refreshToken
    }
    func clearTokens() throws {
        access = nil
        refresh = nil
    }
}

private final class LoginUseCaseSpy: LoginUseCaseProtocol {
    var callCount = 0
    var error: Error?
    var onExecute: (@Sendable () async -> Void)?

    func execute(input: LoginInput) async throws -> AuthenticatedSession {
        callCount += 1
        await onExecute?()
        if let error { throw error }
        return AuthenticatedSession(
            accessToken: "access",
            refreshToken: "refresh",
            user: .init(
                id: 1,
                email: input.email,
                firstName: "Ehab",
                lastName: "Salah",
                role: "CUSTOMER",
                homeAddress: "Cairo",
                dateOfBirth: "1995-04-23"
            )
        )
    }
}
