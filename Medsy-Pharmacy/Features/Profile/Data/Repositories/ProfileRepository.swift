//
//  ProfileRepository.swift
//  Medsy-Pharmacy
//

import Foundation

final class ProfileRepository: ProfileRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private let tokenStore: TokenStoreProtocol

    init(networkService: NetworkServiceProtocol, tokenStore: TokenStoreProtocol) {
        self.networkService = networkService
        self.tokenStore = tokenStore
    }

    // MARK: - Fetch

    func fetchProfile() async throws -> PharmacyProfile {
        let pharmacistEnvelope: PharmacistMeResponseEnvelope = try await networkService.request(
            endpoint: ProfileEndpoint.fetchPharmacistMe
        )

        var pharmacyData: PharmacyMineResponseDTO?
        if let pharmacyId = pharmacistEnvelope.data.pharmacyId, pharmacyId != 0 {
            do {
                let pharmacyEnvelope: PharmacyMineEnvelope = try await networkService.request(
                    endpoint: ProfileEndpoint.fetchPharmacyMine
                )
                pharmacyData = pharmacyEnvelope.data
            } catch {
                // Pharmacist is not yet assigned to a pharmacy or pharmacy not found
                switch error {
                case NetworkError.notFound, NetworkError.validationError:
                    pharmacyData = nil
                default:
                    throw error
                }
            }
        }

        return PharmacyProfileMapper.toDomain(
            pharmacist: pharmacistEnvelope.data,
            pharmacy: pharmacyData
        )
    }

    // MARK: - Personal Profile

    func updateProfile(
        id: Int,
        email: String,
        firstName: String,
        lastName: String,
        homeAddress: String?,
        dateOfBirth: Date?
    ) async throws {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dobString = dateOfBirth.map { formatter.string(from: $0) }

        let request = UpdatePharmacyProfileRequestDTO(
            email: nil,
            firstName: nil,
            lastName: nil,
            homeAddress: homeAddress,
            dob: dobString
        )

        let _: EmptyResponse = try await networkService.request(
            endpoint: ProfileEndpoint.updateMyProfile(request: request)
        )
    }

    // MARK: - Pharmacy Actions

    func leavePharmacy(pharmacyId: Int) async throws {
        let _: EmptyResponse = try await networkService.request(
            endpoint: ProfileEndpoint.leavePharmacy(pharmacyId: pharmacyId)
        )
    }

    func updatePharmacy(
        id: Int,
        name: String?,
        address: String?,
        phoneNumber: String?
    ) async throws {
        let request = UpdatePharmacyRequestDTO(
            name: name,
            address: address,
            phoneNumber: phoneNumber
        )
        let _: EmptyResponse = try await networkService.request(
            endpoint: ProfileEndpoint.updatePharmacy(id: id, request: request)
        )
    }

    func deletePharmacy(id: Int) async throws {
        let _: EmptyResponse = try await networkService.request(
            endpoint: ProfileEndpoint.deletePharmacy(id: id)
        )
    }

    func removePharmacist(pharmacistId: Int, pharmacyId: Int) async throws {
        let _: EmptyResponse = try await networkService.request(
            endpoint: ProfileEndpoint.removePharmacist(pharmacistId: pharmacistId, pharmacyId: pharmacyId)
        )
    }

    func invitePharmacist(pharmacyId: Int, email: String) async throws -> PharmacyInvitation {
        let envelope: PharmacyInvitationEnvelope = try await networkService.request(
            endpoint: ProfileEndpoint.invitePharmacist(
                pharmacyId: pharmacyId,
                request: InvitePharmacistRequestDTO(email: email)
            )
        )
        let data = envelope.data
        return PharmacyInvitation(
            id: data.id,
            pharmacyId: data.pharmacyId,
            pharmacyName: data.pharmacyName,
            pharmacistId: data.pharmacistId,
            pharmacistFirstName: data.pharmacistFirstName,
            pharmacistLastName: data.pharmacistLastName,
            status: data.status,
            invitedEmail: email
        )
    }

    func updatePharmacist(
        id: Int,
        email: String?,
        firstName: String?,
        lastName: String?,
        homeAddress: String?,
        dateOfBirth: Date?
    ) async throws {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dobString = dateOfBirth.map { formatter.string(from: $0) }

        let request = UpdatePharmacyProfileRequestDTO(
            email: email,
            firstName: firstName,
            lastName: lastName,
            homeAddress: homeAddress,
            dob: dobString
        )

        let _: EmptyResponse = try await networkService.request(
            endpoint: ProfileEndpoint.updateUser(id: id, request: request)
        )
    }

    // MARK: - Auth

    func logout() async throws {
        guard let refreshToken = tokenStore.refreshToken() else { return }
        let _: EmptyResponse = try await networkService.request(
            endpoint: ProfileEndpoint.logout(refreshToken: refreshToken)
        )
    }

    // MARK: - Presence

    func goOnDuty() async throws -> PresenceStatus {
        let envelope: PresenceEnvelope = try await networkService.request(
            endpoint: ProfileEndpoint.goOnDuty
        )
        return presenceStatus(from: envelope.data)
    }

    func goOffDuty() async throws -> PresenceStatus {
        let envelope: PresenceEnvelope = try await networkService.request(
            endpoint: ProfileEndpoint.goOffDuty
        )
        return presenceStatus(from: envelope.data)
    }

    // MARK: - Helpers

    private func presenceStatus(from dto: PresenceResponseDTO) -> PresenceStatus {
        var heartbeat: Date?
        if let raw = dto.lastHeartbeatAt {
            heartbeat = ISO8601DateFormatter().date(from: raw)
        }
        return PresenceStatus(onDuty: dto.onDuty, lastHeartbeatAt: heartbeat)
    }
}

struct EmptyResponse: Decodable {}

