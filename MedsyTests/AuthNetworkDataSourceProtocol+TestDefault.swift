@testable import Medsy

// Legacy authentication spies do not exercise logout. Keep their conformance
// focused on the behavior under test without weakening the production protocol.
extension AuthNetworkDataSourceProtocol {
    func logout(request: LogoutRequestDTO) async throws {}

    func requestPasswordReset(request: ForgotPasswordRequestDTO) async throws {
        throw NetworkError.decodingFailed
    }

    func verifyPasswordReset(
        request: VerifyPasswordResetRequestDTO
    ) async throws -> PasswordResetVerificationDataDTO {
        throw NetworkError.decodingFailed
    }

    func resetPassword(request: ResetPasswordRequestDTO) async throws {
        throw NetworkError.decodingFailed
    }
}
