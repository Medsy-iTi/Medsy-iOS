//
//  VerificationSessionIntegrationTests.swift
//  MedsyTests
//
//  Created by Ehab Salah on 17/07/2026.
//

import Alamofire
import XCTest
@testable import Medsy

final class VerificationSessionIntegrationTests: XCTestCase {
    func testVerificationRequestEncodesExactAPIContract() throws {
        let request = VerificationRequestDTO(input: VerificationInput(email: "user@example.com", otpCode: "123456"))
        let data = try JSONEncoder().encode(request)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: String])

        XCTAssertEqual(json, ["email": "user@example.com", "otpCode": "123456"])
    }

    func testRefreshRequestEncodesExactAPIContract() throws {
        let request = RefreshTokenRequestDTO(refreshToken: "refresh-token")
        let data = try JSONEncoder().encode(request)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: String])

        XCTAssertEqual(json, ["refreshToken": "refresh-token"])
    }

    func testAuthEndpointsUseExpectedPostPaths() {
        XCTAssertEqual(AuthEndpoint.verify(VerificationRequestDTO(input: .init(email: "user@example.com", otpCode: "123456"))).path, "auth/verify")
        XCTAssertEqual(AuthEndpoint.refresh(RefreshTokenRequestDTO(refreshToken: "refresh-token")).path, "auth/refresh")
        XCTAssertEqual(AuthEndpoint.verify(VerificationRequestDTO(input: .init(email: "user@example.com", otpCode: "123456"))).method, .post)
        XCTAssertEqual(AuthEndpoint.refresh(RefreshTokenRequestDTO(refreshToken: "refresh-token")).method, .post)
    }

    func testVerificationRepositoryAndUseCaseForwardInputAndStoreSession() async throws {
        let session = makeSession()
        let dataSource = VerificationDataSourceSpy(session: session)
        let repository = AuthRepository(networkDataSource: dataSource)
        let tokenStore = TokenStoreSpy()
        let useCase = VerificationUseCase(repository: repository, tokenStore: tokenStore)
        let input = VerificationInput(email: "user@example.com", otpCode: "123456")

        let result = try await useCase.execute(input: input)

        XCTAssertEqual(dataSource.verificationRequest, VerificationRequestDTO(input: input))
        XCTAssertEqual(result, session)
        XCTAssertEqual(tokenStore.access, session.accessToken)
        XCTAssertEqual(tokenStore.refresh, session.refreshToken)
    }

    func testVerificationDataSourceUsesNetworkService() async throws {
        let networkService = VerificationNetworkServiceSpy()
        networkService.response = AuthSessionResponseDTO(success: true, message: "Verified", data: makeSessionDTO())
        let dataSource = AuthNetworkDataSource(networkService: networkService)

        let session = try await dataSource.verify(
            request: VerificationRequestDTO(input: .init(email: "user@example.com", otpCode: "123456"))
        )

        XCTAssertEqual(networkService.capturedEndpoint?.path, "auth/verify")
        XCTAssertEqual(networkService.capturedEndpoint?.method, .post)
        XCTAssertEqual(session.accessToken, "access")
    }

    @MainActor
    func testVerificationViewModelValidatesOTPBeforeCallingAPI() async {
        let useCase = VerificationUseCaseSpy()
        let viewModel = VerificationViewModel(verificationUseCase: useCase)
        viewModel.updateCode("123")

        let succeeded = await viewModel.submit(email: "user@example.com")

        XCTAssertFalse(succeeded)
        XCTAssertEqual(useCase.callCount, 0)
        XCTAssertNotNil(viewModel.validationMessage)
        XCTAssertNil(viewModel.state)
    }

    @MainActor
    func testVerificationViewModelTransitionsToSuccessAndBlocksDuplicateSubmissions() async {
        let useCase = VerificationUseCaseSpy()
        useCase.onExecute = { try? await Task.sleep(for: .milliseconds(100)) }
        let viewModel = VerificationViewModel(verificationUseCase: useCase)
        viewModel.updateCode("123456")

        async let firstSubmission = viewModel.submit(email: "user@example.com")
        await Task.yield()
        let duplicateSubmission = await viewModel.submit(email: "user@example.com")
        let firstSucceeded = await firstSubmission

        XCTAssertTrue(firstSucceeded)
        XCTAssertFalse(duplicateSubmission)
        XCTAssertEqual(useCase.callCount, 1)
        XCTAssertEqual(viewModel.state, .success)
    }

    @MainActor
    func testVerificationViewModelExposesAPIErrorForValidationAndAlert() async {
        let useCase = VerificationUseCaseSpy()
        useCase.error = NetworkError.validationError("Invalid verification code")
        let viewModel = VerificationViewModel(verificationUseCase: useCase)
        viewModel.updateCode("123456")

        let succeeded = await viewModel.submit(email: "user@example.com")

        XCTAssertFalse(succeeded)
        XCTAssertEqual(viewModel.state, .error("Invalid verification code"))
        XCTAssertEqual(viewModel.validationMessage, "Invalid verification code")
        XCTAssertEqual(viewModel.alertMessage, "Invalid verification code")
    }

    func testTokenStoreSavesRotatesAndClearsTokens() throws {
        let tokenStore = KeychainTokenStore(service: "com.medsy.tests.\(UUID().uuidString)")
        defer { try? tokenStore.clearTokens() }

        try tokenStore.save(accessToken: "access-1", refreshToken: "refresh-1")
        XCTAssertEqual(tokenStore.accessToken(), "access-1")
        XCTAssertEqual(tokenStore.refreshToken(), "refresh-1")

        try tokenStore.save(accessToken: "access-2", refreshToken: "refresh-2")
        XCTAssertEqual(tokenStore.accessToken(), "access-2")
        XCTAssertEqual(tokenStore.refreshToken(), "refresh-2")

        try tokenStore.clearTokens()
        XCTAssertNil(tokenStore.accessToken())
        XCTAssertNil(tokenStore.refreshToken())
    }

    func testAuthenticatedRequestAddsBearerHeader() throws {
        let tokenStore = TokenStoreSpy(access: "access-token", refresh: "refresh-token")
        let builder = NetworkRequestBuilder(languageManager: .shared)
        let request = try builder.makeRequest(for: ProtectedEndpoint(), accessToken: tokenStore.accessToken())

        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer access-token")
    }

    func testNetworkServiceRefreshesOnceAndRetriesProtectedRequest() async throws {
        let transport = TransportSpy(responses: [
            NetworkResponse(data: nil, statusCode: 401),
            NetworkResponse(data: successData(), statusCode: 200)
        ])
        let tokenStore = TokenStoreSpy(access: "expired", refresh: "refresh")
        let refresher = TokenRefresherSpy { tokenStore.access = "rotated" }
        let service = NetworkService(
            transport: transport,
            requestBuilder: NetworkRequestBuilder(languageManager: .shared),
            tokenStore: tokenStore,
            tokenRefresher: refresher
        )

        let response: TestResponse = try await service.request(endpoint: ProtectedEndpoint())

        XCTAssertEqual(response.value, "ok")
        XCTAssertEqual(refresher.callCount, 1)
        XCTAssertEqual(transport.requests.count, 2)
        XCTAssertEqual(transport.requests.last?.value(forHTTPHeaderField: "Authorization"), "Bearer rotated")
    }

    func testRefreshFailureClearsTokensAndReturnsUnauthorized() async {
        let transport = TransportSpy(responses: [NetworkResponse(data: nil, statusCode: 401)])
        let tokenStore = TokenStoreSpy(access: "expired", refresh: "refresh")
        let service = NetworkService(
            transport: transport,
            requestBuilder: NetworkRequestBuilder(languageManager: .shared),
            tokenStore: tokenStore,
            tokenRefresher: TokenRefresherSpy(error: NetworkError.unauthorized)
        )

        do {
            let _: TestResponse = try await service.request(endpoint: ProtectedEndpoint())
            XCTFail("Expected an unauthorized error")
        } catch let error as NetworkError {
            XCTAssertEqual(error.errorDescription, NetworkError.unauthorized.errorDescription)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        XCTAssertNil(tokenStore.access)
        XCTAssertNil(tokenStore.refresh)
    }

    func testAuthEndpointsDoNotRequireAuthentication() {
        XCTAssertFalse(AuthEndpoint.verify(VerificationRequestDTO(input: .init(email: "user@example.com", otpCode: "123456"))).requiresAuthentication)
        XCTAssertFalse(AuthEndpoint.refresh(RefreshTokenRequestDTO(refreshToken: "refresh-token")).requiresAuthentication)
    }

    private func makeSession() -> AuthenticatedSession {
        AuthenticatedSession(accessToken: "access", refreshToken: "refresh", user: .init(id: 1, email: "user@example.com", firstName: "Ehab", lastName: "Salah", role: "CUSTOMER", homeAddress: "Cairo", dateOfBirth: "1995-04-23"))
    }

    private func makeSessionDTO() -> AuthSessionDTO {
        AuthSessionDTO(accessToken: "access", refreshToken: "refresh", user: .init(id: 1, email: "user@example.com", firstName: "Ehab", lastName: "Salah", role: "CUSTOMER", homeAddress: "Cairo", dob: "1995-04-23"))
    }

    private func successData() -> Data {
        #"{"value":"ok"}"#.data(using: .utf8)!
    }
}

private final class VerificationDataSourceSpy: AuthNetworkDataSourceProtocol {
    let session: AuthenticatedSession
    var verificationRequest: VerificationRequestDTO?

    init(session: AuthenticatedSession) { self.session = session }
    func register(request: SignupRequestDTO) async throws {}
    func verify(request: VerificationRequestDTO) async throws -> AuthSessionDTO {
        verificationRequest = request
        return AuthSessionDTO(accessToken: session.accessToken, refreshToken: session.refreshToken, user: .init(id: session.user.id, email: session.user.email, firstName: session.user.firstName, lastName: session.user.lastName, role: session.user.role, homeAddress: session.user.homeAddress, dob: session.user.dateOfBirth))
    }
}

private final class VerificationNetworkServiceSpy: NetworkServiceProtocol {
    var capturedEndpoint: ApiEndpoint?
    var response: Any?

    func request<T: Decodable>(endpoint: ApiEndpoint) async throws -> T {
        capturedEndpoint = endpoint
        guard let response = response as? T else { throw NetworkError.decodingFailed }
        return response
    }
}

private final class VerificationUseCaseSpy: VerificationUseCaseProtocol {
    var callCount = 0
    var error: Error?
    var onExecute: (@Sendable () async -> Void)?

    func execute(input: VerificationInput) async throws -> AuthenticatedSession {
        callCount += 1
        await onExecute?()
        if let error { throw error }
        return AuthenticatedSession(accessToken: "access", refreshToken: "refresh", user: .init(id: 1, email: input.email, firstName: "", lastName: "", role: "CUSTOMER", homeAddress: "", dateOfBirth: ""))
    }
}

private final class TokenStoreSpy: TokenStoreProtocol {
    var access: String?
    var refresh: String?

    init(access: String? = nil, refresh: String? = nil) {
        self.access = access
        self.refresh = refresh
    }
    func accessToken() -> String? { access }
    func refreshToken() -> String? { refresh }
    func save(accessToken: String, refreshToken: String) throws { access = accessToken; refresh = refreshToken }
    func clearTokens() throws { access = nil; refresh = nil }
}

private final class TokenRefresherSpy: TokenRefreshing {
    var callCount = 0
    let action: (() throws -> Void)?

    init(action: (() throws -> Void)? = nil, error: Error? = nil) {
        if let error { self.action = { throw error } } else { self.action = action }
    }
    func refreshTokens() async throws { callCount += 1; try action?() }
}

private final class TransportSpy: NetworkTransportProtocol {
    var responses: [NetworkResponse]
    var requests: [URLRequest] = []

    init(responses: [NetworkResponse]) { self.responses = responses }
    func execute(_ request: URLRequest) async throws -> NetworkResponse {
        requests.append(request)
        return responses.removeFirst()
    }
}

private struct ProtectedEndpoint: ApiEndpoint {
    let path = "protected"
    let method: HTTPMethod = .get
    let body: Data? = nil
    let requiresAuthentication = true
}

private struct TestResponse: Decodable { let value: String }
