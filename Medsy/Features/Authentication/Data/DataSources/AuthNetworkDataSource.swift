//
//  AuthNetworkDataSource.swift
//  Medsy
//
//  Created by Ehab Salah on 17/07/2026.
//

protocol AuthNetworkDataSourceProtocol {
    func login(request: LoginRequestDTO) async throws -> AuthSessionDTO
    func register(request: SignupRequestDTO) async throws
    func verify(request: VerificationRequestDTO) async throws -> AuthSessionDTO
    func logout(request: LogoutRequestDTO) async throws
}

final class AuthNetworkDataSource: AuthNetworkDataSourceProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func login(request: LoginRequestDTO) async throws -> AuthSessionDTO {
        let response: AuthSessionResponseDTO = try await networkService.request(
            endpoint: AuthEndpoint.login(request)
        )
        guard response.success else { throw NetworkError.validationError(response.message) }
        guard let session = response.data else { throw NetworkError.decodingFailed }
        return session
    }

    func register(request: SignupRequestDTO) async throws {
        let response: SignupResponseDTO = try await networkService.request(
            endpoint: AuthEndpoint.register(request)
        )

        guard response.success else {
            throw NetworkError.validationError(response.message)
        }
    }

    func verify(request: VerificationRequestDTO) async throws -> AuthSessionDTO {
        let response: AuthSessionResponseDTO = try await networkService.request(
            endpoint: AuthEndpoint.verify(request)
        )
        guard response.success else { throw NetworkError.validationError(response.message) }
        guard let session = response.data else { throw NetworkError.decodingFailed }
        return session
    }

    func logout(request: LogoutRequestDTO) async throws {
        let response: LogoutResponseDTO = try await networkService.request(
            endpoint: AuthEndpoint.logout(request)
        )
        guard response.success else {
            throw NetworkError.validationError(response.message)
        }
    }
}
