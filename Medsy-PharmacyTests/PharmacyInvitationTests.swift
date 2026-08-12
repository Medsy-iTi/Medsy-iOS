import Alamofire
import XCTest
@testable import Medsy_Pharmacy

final class PharmacyInvitationDTOTests: XCTestCase {
    func testPendingInvitationResponseDecodesAndMapsProductionFields() throws {
        let data = Data(
            """
            {
              "success": true,
              "message": "Pending pharmacy invitations fetched",
              "data": [{
                "id": 17,
                "pharmacyId": 4,
                "pharmacyName": "Al Amal Pharmacy",
                "pharmacistId": 9,
                "pharmacistFirstName": "Ahmed",
                "pharmacistLastName": "Elkady",
                "status": "PENDING",
                "createdAt": "2026-07-22T08:30:00Z"
              }]
            }
            """.utf8
        )

        let response = try JSONDecoder().decode(PendingPharmacyInvitationsEnvelopeDTO.self, from: data)
        let invitation = try XCTUnwrap(response.data?.first?.toDomain())

        XCTAssertEqual(invitation.id, 17)
        XCTAssertEqual(invitation.pharmacyID, 4)
        XCTAssertEqual(invitation.pharmacyName, "Al Amal Pharmacy")
        XCTAssertEqual(invitation.status, .pending)
        XCTAssertNotNil(invitation.createdAt)
    }

    func testInvitationEndpointsMatchProductionContract() {
        XCTAssertEqual(PharmacyInvitationEndpoint.pending.path, "pharmacy-invitations/me")
        XCTAssertEqual(PharmacyInvitationEndpoint.pending.method, .get)
        XCTAssertEqual(PharmacyInvitationEndpoint.accept(id: 12).path, "pharmacy-invitations/12/accept")
        XCTAssertEqual(PharmacyInvitationEndpoint.accept(id: 12).method, .patch)
        XCTAssertEqual(PharmacyInvitationEndpoint.decline(id: 12).path, "pharmacy-invitations/12/decline")
        XCTAssertEqual(PharmacyInvitationEndpoint.decline(id: 12).method, .patch)
        XCTAssertTrue(PharmacyInvitationEndpoint.pending.requiresAuthentication)
    }
}

@MainActor
final class PharmacyInvitationsViewModelTests: XCTestCase {
    func testLoadShowsOnlyPendingInvitationsAndBadgeCount() async {
        let older = invitation(id: 1, status: .pending, createdAt: Date(timeIntervalSince1970: 10))
        let newer = invitation(id: 2, status: .pending, createdAt: Date(timeIntervalSince1970: 20))
        let accepted = invitation(id: 3, status: .accepted, createdAt: Date(timeIntervalSince1970: 30))
        let viewModel = makeViewModel(load: { [older, newer, accepted] })

        await viewModel.load()

        XCTAssertEqual(viewModel.state, .content)
        XCTAssertEqual(viewModel.invitations.map(\.id), [2, 1])
        XCTAssertEqual(viewModel.pendingCount, 2)
    }

    func testDecliningInvitationRemovesItAndShowsEmptyState() async {
        let pending = invitation(id: 8)
        let viewModel = makeViewModel(
            load: { [pending] },
            decline: { id in Self.invitation(id: id, status: .declined) }
        )
        await viewModel.load()

        await viewModel.declineInvitation(id: pending.id)

        XCTAssertEqual(viewModel.state, .empty)
        XCTAssertEqual(viewModel.pendingCount, 0)
    }

    func testAcceptingInvitationReturnsSuccessAndRemovesIt() async {
        let pending = invitation(id: 21)
        let viewModel = makeViewModel(
            load: { [pending] },
            accept: { id in Self.invitation(id: id, status: .accepted) }
        )
        await viewModel.load()

        let accepted = await viewModel.acceptInvitation(id: pending.id)

        XCTAssertTrue(accepted)
        XCTAssertEqual(viewModel.state, .empty)
        XCTAssertEqual(viewModel.pendingCount, 0)
    }

    func testLoadFailureExposesRetryableErrorState() async {
        let viewModel = makeViewModel(load: { throw InvitationTestError.failed })

        await viewModel.load()

        XCTAssertEqual(viewModel.state, .error("Invitation request failed"))
    }

    private func makeViewModel(
        load: @escaping () async throws -> [PendingPharmacyInvitation],
        accept: ((Int) async throws -> PendingPharmacyInvitation)? = nil,
        decline: ((Int) async throws -> PendingPharmacyInvitation)? = nil
    ) -> PharmacyInvitationsViewModel {
        PharmacyInvitationsViewModel(
            loadAction: load,
            acceptAction: accept ?? { id in Self.invitation(id: id, status: .accepted) },
            declineAction: decline ?? { id in Self.invitation(id: id, status: .declined) }
        )
    }

    private static func invitation(
        id: Int,
        status: PharmacyInvitationStatus = .pending,
        createdAt: Date? = nil
    ) -> PendingPharmacyInvitation {
        PendingPharmacyInvitation(
            id: id,
            pharmacyID: 4,
            pharmacyName: "Al Amal Pharmacy",
            pharmacistID: 9,
            pharmacistFirstName: "Ahmed",
            pharmacistLastName: "Elkady",
            status: status,
            createdAt: createdAt
        )
    }

    private func invitation(
        id: Int,
        status: PharmacyInvitationStatus = .pending,
        createdAt: Date? = nil
    ) -> PendingPharmacyInvitation {
        Self.invitation(id: id, status: status, createdAt: createdAt)
    }
}

private enum InvitationTestError: LocalizedError {
    case failed

    var errorDescription: String? { "Invitation request failed" }
}

@MainActor
final class RootCoordinatorSessionRoutingTests: XCTestCase {
    func testStoredSessionReturnsToAuthenticationForMembershipResolution() {
        let tokenStore = SessionRoutingTokenStore(accessToken: "stored-access-token")
        let coordinator = makeCoordinator(tokenStore: tokenStore, hasCompletedOnboarding: true)

        coordinator.finishSplash()

        XCTAssertTrue(coordinator.isAuthenticated)
        XCTAssertEqual(coordinator.flow, .authentication)
    }

    func testReturningToSignInClearsStoredSession() {
        let tokenStore = SessionRoutingTokenStore(accessToken: "stored-access-token")
        let coordinator = makeCoordinator(tokenStore: tokenStore, hasCompletedOnboarding: true)

        coordinator.returnToSignIn()

        XCTAssertFalse(coordinator.isAuthenticated)
        XCTAssertNil(tokenStore.accessToken())
        XCTAssertEqual(coordinator.flow, .authentication)
    }

    private func makeCoordinator(
        tokenStore: SessionRoutingTokenStore,
        hasCompletedOnboarding: Bool
    ) -> RootCoordinator {
        let container = PharmacyDIContainer()
        container.register(HasCompletedOnboardingUseCaseProtocol.self) { _ in
            SessionRoutingOnboardingStatus(completed: hasCompletedOnboarding)
        }
        container.register(CompleteOnboardingUseCaseProtocol.self) { _ in
            SessionRoutingCompleteOnboarding()
        }
        container.register(TokenStoreProtocol.self) { _ in tokenStore }
        return RootCoordinator(container: container)
    }
}

private struct SessionRoutingOnboardingStatus: HasCompletedOnboardingUseCaseProtocol {
    let completed: Bool
    func execute() -> Bool { completed }
}

private struct SessionRoutingCompleteOnboarding: CompleteOnboardingUseCaseProtocol {
    func execute() {}
}

private final class SessionRoutingTokenStore: TokenStoreProtocol {
    private var storedAccessToken: String?
    private var storedRefreshToken: String?

    init(accessToken: String?) {
        storedAccessToken = accessToken
        storedRefreshToken = accessToken == nil ? nil : "stored-refresh-token"
    }

    func accessToken() -> String? { storedAccessToken }
    func refreshToken() -> String? { storedRefreshToken }

    func save(accessToken: String, refreshToken: String) throws {
        storedAccessToken = accessToken
        storedRefreshToken = refreshToken
    }

    func clearTokens() throws {
        storedAccessToken = nil
        storedRefreshToken = nil
    }
}
