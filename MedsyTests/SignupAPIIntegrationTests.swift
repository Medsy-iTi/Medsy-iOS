//
//  SignupAPIIntegrationTests.swift
//  MedsyTests
//
//  Created by Ehab Salah on 17/07/2026.
//

import XCTest
@testable import Medsy

final class SignupAPIIntegrationTests: XCTestCase {
    func testSignupRequestEncodesExactAPIContract() throws {
        let input = makeInput()
        let request = SignupRequestDTO(input: input)
        let data = try JSONEncoder().encode(request)
        let json = try XCTUnwrap(
            JSONSerialization.jsonObject(with: data) as? [String: Any]
        )

        XCTAssertEqual(Set(json.keys), [
            "email", "phoneNumber", "firstName", "lastName", "password",
            "role", "homeAddress", "dob", "pharmacyId"
        ])
        XCTAssertEqual(json["email"] as? String, input.email)
        XCTAssertEqual(json["phoneNumber"] as? String, input.phoneNumber)
        XCTAssertEqual(json["firstName"] as? String, input.firstName)
        XCTAssertEqual(json["lastName"] as? String, input.lastName)
        XCTAssertEqual(json["password"] as? String, input.password)
        XCTAssertEqual(json["role"] as? String, "CUSTOMER")
        XCTAssertEqual(json["homeAddress"] as? String, input.homeAddress)
        XCTAssertEqual(json["dob"] as? String, "1995-04-23")
        XCTAssertEqual(json["pharmacyId"] as? Int, 0)
        XCTAssertNil(json["confirmedPassword"])
    }

    func testAuthEndpointUsesRegisterPathAndPostMethod() throws {
        let endpoint = AuthEndpoint.register(SignupRequestDTO(input: makeInput()))

        XCTAssertEqual(endpoint.path, "auth/register")
        XCTAssertEqual(endpoint.method, .post)
        XCTAssertNotNil(endpoint.body)
    }

    func testNetworkDataSourceUsesNetworkService() async throws {
        let networkService = NetworkServiceSpy()
        networkService.response = SignupResponseDTO(
            success: true,
            message: "Registration initiated successfully."
        )
        let dataSource = AuthNetworkDataSource(networkService: networkService)

        try await dataSource.register(request: SignupRequestDTO(input: makeInput()))

        XCTAssertEqual(networkService.capturedEndpoint?.path, "auth/register")
        XCTAssertEqual(networkService.capturedEndpoint?.method, .post)
    }

    func testRepositoryAndUseCaseForwardSignupInput() async throws {
        let dataSource = AuthNetworkDataSourceSpy()
        let repository = AuthRepository(networkDataSource: dataSource)
        let useCase = SignupUseCase(repository: repository)
        let input = makeInput()

        try await useCase.execute(input: input)

        XCTAssertEqual(dataSource.receivedRequest, SignupRequestDTO(input: input))
    }

    func testNetworkErrorHandlerExtractsBackendMessageFromFailedEnvelope() throws {
        let data = try XCTUnwrap(
            #"{"success":false,"message":"Email already exists","data":null}"#
                .data(using: .utf8)
        )

        let error = try XCTUnwrap(NetworkErrorHandler.apiEnvelopeError(from: data))

        guard case .validationError(let message) = error else {
            return XCTFail("Expected a validation error")
        }
        XCTAssertEqual(message, "Email already exists")
    }

    func testNetworkErrorHandlerPrioritizesEnvelopeMessageOverHTTPStatus() throws {
        let data = try XCTUnwrap(
            #"{"success":false,"message":"Email already exists","data":null}"#
                .data(using: .utf8)
        )

        let error = NetworkErrorHandler.map(
            error: SignupTestError.invalidResponseType,
            statusCode: 400,
            data: data
        )

        guard case .validationError(let message) = error else {
            return XCTFail("Expected the API envelope message")
        }
        XCTAssertEqual(message, "Email already exists")
    }

    func testNetworkErrorHandlerUsesResponseMessageFor422() throws {
        let data = try XCTUnwrap(
            #"{"success":false,"message":"Email format is invalid","data":null}"#
                .data(using: .utf8)
        )

        let error = NetworkErrorHandler.map(
            error: SignupTestError.invalidResponseType,
            statusCode: 422,
            data: data
        )

        guard case .validationError(let message) = error else {
            return XCTFail("Expected a validation error")
        }
        XCTAssertEqual(message, "Email format is invalid")
    }

    @MainActor
    func testViewModelTransitionsFromLoadingToSuccess() async {
        let useCase = SignupUseCaseSpy()
        let viewModel = makeValidViewModel(useCase: useCase)
        useCase.onExecute = {
            XCTAssertEqual(viewModel.state, .loading)
        }

        let succeeded = await viewModel.submit()

        XCTAssertTrue(succeeded)
        XCTAssertEqual(viewModel.state, .success)
        XCTAssertEqual(useCase.executeCallCount, 1)
        XCTAssertEqual(useCase.receivedInput?.email, "user@example.com")
    }

    @MainActor
    func testViewModelTransitionsFromLoadingToError() async {
        let useCase = SignupUseCaseSpy()
        useCase.error = NetworkError.validationError("Email already exists")
        let viewModel = makeValidViewModel(useCase: useCase)

        let succeeded = await viewModel.submit()

        XCTAssertFalse(succeeded)
        XCTAssertEqual(viewModel.state, .error("Email already exists"))
        XCTAssertEqual(viewModel.alertMessage, "Email already exists")

        viewModel.dismissError()
        XCTAssertNil(viewModel.state)
        XCTAssertNil(viewModel.alertMessage)
    }

    @MainActor
    func testLocalValidationDoesNotExecuteSignupUseCase() async {
        let useCase = SignupUseCaseSpy()
        let viewModel = SignupViewModel(signupUseCase: useCase)

        let succeeded = await viewModel.submit()

        XCTAssertFalse(succeeded)
        XCTAssertEqual(useCase.executeCallCount, 0)
        XCTAssertNotNil(viewModel.validationMessage)
        XCTAssertNil(viewModel.state)
    }

    private func makeInput() -> SignupInput {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        let dateOfBirth = calendar.date(
            from: DateComponents(year: 1995, month: 4, day: 23, hour: 12)
        )!

        return SignupInput(
            email: "user@example.com",
            phoneNumber: "01289166632",
            firstName: "Ehab",
            lastName: "Salah",
            password: "Password@1",
            homeAddress: "Cairo",
            dateOfBirth: dateOfBirth
        )
    }

    @MainActor
    private func makeValidViewModel(useCase: SignupUseCaseSpy) -> SignupViewModel {
        let viewModel = SignupViewModel(signupUseCase: useCase)
        viewModel.email = "user@example.com"
        viewModel.phoneNumber = "01289166632"
        viewModel.firstName = "Ehab"
        viewModel.lastName = "Salah"
        viewModel.password = "Password@1"
        viewModel.confirmedPassword = "Password@1"
        viewModel.homeAddress = "Cairo"
        return viewModel
    }
}

private enum SignupTestError: Error {
    case invalidResponseType
}

private final class NetworkServiceSpy: NetworkServiceProtocol {
    var capturedEndpoint: ApiEndpoint?
    var response: Any?
    var error: Error?

    func request<T: Decodable>(endpoint: ApiEndpoint) async throws -> T {
        capturedEndpoint = endpoint
        if let error { throw error }
        guard let response = response as? T else {
            throw SignupTestError.invalidResponseType
        }
        return response
    }

    func requestData(endpoint: ApiEndpoint) async throws -> Data {
        Data()
    }

    func streamSSE(endpoint: ApiEndpoint) -> AsyncThrowingStream<SSEEvent, Error> {
        AsyncThrowingStream { continuation in
            continuation.finish()
        }
    }
}

private final class AuthNetworkDataSourceSpy: AuthNetworkDataSourceProtocol {
    var receivedRequest: SignupRequestDTO?

    func login(request: LoginRequestDTO) async throws -> AuthSessionDTO {
        throw SignupTestError.invalidResponseType
    }

    func register(request: SignupRequestDTO) async throws {
        receivedRequest = request
    }

    func verify(request: VerificationRequestDTO) async throws -> AuthSessionDTO {
        throw SignupTestError.invalidResponseType
    }

    func logout(request: LogoutRequestDTO) async throws {}
}

private final class SignupUseCaseSpy: SignupUseCaseProtocol {
    var receivedInput: SignupInput?
    var executeCallCount = 0
    var error: Error?
    var onExecute: (@MainActor () -> Void)?

    func execute(input: SignupInput) async throws {
        receivedInput = input
        executeCallCount += 1
        await onExecute?()
        if let error { throw error }
    }
}
