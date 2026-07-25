//
//  ProfilePresenceTests.swift
//  Medsy-PharmacyTests
//

import Alamofire
import XCTest
@testable import Medsy_Pharmacy

final class PresenceDTOTests: XCTestCase {
    func testPresenceResponseDTODecodesSuccessfully() throws {
        let json = """
        {
            "success": true,
            "message": "Pharmacist is now on-duty",
            "data": {
                "lastHeartbeatAt": "2026-07-24T12:00:00Z",
                "onDuty": true
            }
        }
        """
        let data = Data(json.utf8)
        let envelope = try JSONDecoder().decode(PresenceEnvelope.self, from: data)

        XCTAssertTrue(envelope.success)
        XCTAssertEqual(envelope.message, "Pharmacist is now on-duty")
        let presenceData = try XCTUnwrap(envelope.data)
        XCTAssertTrue(presenceData.onDuty)
        XCTAssertEqual(presenceData.lastHeartbeatAt, "2026-07-24T12:00:00Z")
    }

    func testPresenceEndpointsMatchProductionContract() {
        XCTAssertEqual(PresenceEndpoint.goOnDuty.path, "pharmacists/me/presence/on-duty")
        XCTAssertEqual(PresenceEndpoint.goOnDuty.method, .post)
        XCTAssertTrue(PresenceEndpoint.goOnDuty.requiresAuthentication)

        XCTAssertEqual(PresenceEndpoint.goOffDuty.path, "pharmacists/me/presence/off-duty")
        XCTAssertEqual(PresenceEndpoint.goOffDuty.method, .post)
        XCTAssertTrue(PresenceEndpoint.goOffDuty.requiresAuthentication)

        XCTAssertEqual(PresenceEndpoint.heartbeat.path, "pharmacists/me/presence/heartbeat")
        XCTAssertEqual(PresenceEndpoint.heartbeat.method, .post)
        XCTAssertTrue(PresenceEndpoint.heartbeat.requiresAuthentication)
    }
}

@MainActor
final class ProfileViewModelPresenceTests: XCTestCase {
    func testTogglePresenceTurnsOnDutyAndTriggersToast() async {
        var didCallGoOnDuty = false
        let mockGoOnDuty = MockGoOnDutyUseCase {
            didCallGoOnDuty = true
            return PresenceEntity(lastHeartbeatAt: "2026-07-24T12:00:00Z", onDuty: true)
        }
        let mockGoOffDuty = MockGoOffDutyUseCase {
            PresenceEntity(lastHeartbeatAt: "2026-07-24T12:00:00Z", onDuty: false)
        }

        let viewModel = makeViewModel(
            goOnDutyUseCase: mockGoOnDuty,
            goOffDutyUseCase: mockGoOffDuty
        )

        XCTAssertFalse(viewModel.isOnDuty)

        await viewModel.togglePresence()

        XCTAssertTrue(didCallGoOnDuty)
        XCTAssertTrue(viewModel.isOnDuty)
        XCTAssertTrue(viewModel.showPresenceToast)
        XCTAssertNotNil(viewModel.presenceToastMessage)
        XCTAssertNil(viewModel.presenceErrorMessage)
    }

    func testTogglePresenceTurnsOffDutyAndTriggersToast() async {
        var didCallGoOffDuty = false
        let mockGoOnDuty = MockGoOnDutyUseCase {
            PresenceEntity(lastHeartbeatAt: "2026-07-24T12:00:00Z", onDuty: true)
        }
        let mockGoOffDuty = MockGoOffDutyUseCase {
            didCallGoOffDuty = true
            return PresenceEntity(lastHeartbeatAt: "2026-07-24T12:00:00Z", onDuty: false)
        }

        let viewModel = makeViewModel(
            goOnDutyUseCase: mockGoOnDuty,
            goOffDutyUseCase: mockGoOffDuty
        )

        // Turn on duty first
        await viewModel.togglePresence()
        XCTAssertTrue(viewModel.isOnDuty)

        // Turn off duty
        await viewModel.togglePresence()

        XCTAssertTrue(didCallGoOffDuty)
        XCTAssertFalse(viewModel.isOnDuty)
        XCTAssertTrue(viewModel.showPresenceToast)
        XCTAssertNotNil(viewModel.presenceToastMessage)
        XCTAssertNil(viewModel.presenceErrorMessage)
    }

    func testTogglePresenceFailureSetsErrorMessage() async {
        let mockGoOnDuty = MockGoOnDutyUseCase {
            throw PresenceTestError.networkFailed
        }
        let mockGoOffDuty = MockGoOffDutyUseCase {
            PresenceEntity(lastHeartbeatAt: "2026-07-24T12:00:00Z", onDuty: false)
        }

        let viewModel = makeViewModel(
            goOnDutyUseCase: mockGoOnDuty,
            goOffDutyUseCase: mockGoOffDuty
        )

        await viewModel.togglePresence()

        XCTAssertFalse(viewModel.isOnDuty)
        XCTAssertFalse(viewModel.showPresenceToast)
        XCTAssertNotNil(viewModel.presenceErrorMessage)
    }

    private func makeViewModel(
        goOnDutyUseCase: GoOnDutyUseCaseProtocol,
        goOffDutyUseCase: GoOffDutyUseCaseProtocol
    ) -> ProfileViewModel {
        ProfileViewModel(
            getProfileUseCase: MockGetProfileUseCase(),
            updateProfileUseCase: MockUpdateProfileUseCase(),
            leavePharmacyUseCase: MockLeavePharmacyUseCase(),
            updatePharmacyUseCase: MockUpdatePharmacyUseCase(),
            deletePharmacyUseCase: MockDeletePharmacyUseCase(),
            removePharmacistUseCase: MockRemovePharmacistUseCase(),
            invitePharmacistUseCase: MockInvitePharmacistUseCase(),
            updatePharmacistUseCase: MockUpdatePharmacistUseCase(),
            logoutUseCase: MockLogoutUseCase(),
            goOnDutyUseCase: goOnDutyUseCase,
            goOffDutyUseCase: goOffDutyUseCase,
            languageManager: LanguageManager.shared,
            appSettings: PharmacyAppSettings.shared
        )
    }
}

// MARK: - Mocks & Helpers

private enum PresenceTestError: Error {
    case networkFailed
}

private struct MockGoOnDutyUseCase: GoOnDutyUseCaseProtocol {
    let action: () async throws -> PresenceEntity
    func execute() async throws -> PresenceEntity { try await action() }
}

private struct MockGoOffDutyUseCase: GoOffDutyUseCaseProtocol {
    let action: () async throws -> PresenceEntity
    func execute() async throws -> PresenceEntity { try await action() }
}

private struct MockGetProfileUseCase: GetPharmacyProfileUseCaseProtocol {
    func execute() async throws -> PharmacyProfile {
        PharmacyProfile(
            id: "1",
            firstName: "John",
            lastName: "Doe",
            email: "test@pharmacy.com",
            phoneNumber: "555-0199",
            pharmacyId: 10,
            isPharmacyAdmin: true,
            homeAddress: nil,
            dateOfBirth: nil,
            pharmacyName: "Medsy Test Pharmacy",
            pharmacyAddress: "123 Health St",
            pharmacyPhoneNumber: "555-0199",
            pharmacyMembers: []
        )
    }
}

private struct MockUpdateProfileUseCase: PharmacyUpdateProfileUseCaseProtocol {
    func execute(id: Int, email: String, firstName: String, lastName: String, homeAddress: String?, dateOfBirth: Date?) async throws {}
}

private struct MockLeavePharmacyUseCase: LeavePharmacyUseCaseProtocol {
    func execute(pharmacyId: Int) async throws {}
}

private struct MockUpdatePharmacyUseCase: UpdatePharmacyUseCaseProtocol {
    func execute(id: Int, name: String?, address: String?, phoneNumber: String?) async throws {}
}

private struct MockDeletePharmacyUseCase: DeletePharmacyUseCaseProtocol {
    func execute(id: Int) async throws {}
}

private struct MockRemovePharmacistUseCase: RemovePharmacistUseCaseProtocol {
    func execute(pharmacistId: Int, pharmacyId: Int) async throws {}
}

private struct MockInvitePharmacistUseCase: InvitePharmacistUseCaseProtocol {
    func execute(pharmacyId: Int, email: String) async throws -> PharmacyInvitation {
        PharmacyInvitation(
            id: 1,
            pharmacyId: pharmacyId,
            pharmacyName: "Test Pharmacy",
            pharmacistId: 2,
            pharmacistFirstName: "Jane",
            pharmacistLastName: "Doe",
            status: "PENDING",
            invitedEmail: email
        )
    }
}

private struct MockUpdatePharmacistUseCase: UpdatePharmacistUseCaseProtocol {
    func execute(id: Int, email: String?, firstName: String?, lastName: String?, homeAddress: String?, dateOfBirth: Date?) async throws {}
}

private struct MockLogoutUseCase: LogoutUseCaseProtocol {
    func execute() async {}
}
