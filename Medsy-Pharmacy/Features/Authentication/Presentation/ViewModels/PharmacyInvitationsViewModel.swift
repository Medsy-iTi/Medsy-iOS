import Foundation
import Observation

enum PharmacyInvitationsViewState: Equatable {
    case idle
    case loading
    case content
    case empty
    case error(String)
}

@MainActor
@Observable
final class PharmacyInvitationsViewModel {
    private(set) var state: PharmacyInvitationsViewState = .idle
    private(set) var invitations: [PendingPharmacyInvitation] = []
    private(set) var actingInvitationID: Int?
    private(set) var actionErrorMessage: String?

    private let loadAction: () async throws -> [PendingPharmacyInvitation]
    private let acceptAction: (Int) async throws -> PendingPharmacyInvitation
    private let declineAction: (Int) async throws -> PendingPharmacyInvitation

    init(
        loadAction: @escaping () async throws -> [PendingPharmacyInvitation],
        acceptAction: @escaping (Int) async throws -> PendingPharmacyInvitation,
        declineAction: @escaping (Int) async throws -> PendingPharmacyInvitation
    ) {
        self.loadAction = loadAction
        self.acceptAction = acceptAction
        self.declineAction = declineAction
    }

    var pendingCount: Int { invitations.count }

    func load(force: Bool = false) async {
        guard state != .loading else { return }
        if !force, state == .content || state == .empty { return }

        state = .loading
        do {
            invitations = try (await loadAction())
                .filter { $0.status == .pending }
                .sorted { lhs, rhs in
                    (lhs.createdAt ?? .distantPast) > (rhs.createdAt ?? .distantPast)
                }
            updateContentState()
        } catch is CancellationError {
            state = .idle
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func acceptInvitation(id: Int) async -> Bool {
        guard actingInvitationID == nil,
              invitations.contains(where: { $0.id == id }) else { return false }

        actingInvitationID = id
        actionErrorMessage = nil
        defer { actingInvitationID = nil }

        do {
            _ = try await acceptAction(id)
            invitations.removeAll { $0.id == id }
            updateContentState()
            return true
        } catch is CancellationError {
            return false
        } catch {
            actionErrorMessage = error.localizedDescription
            return false
        }
    }

    func declineInvitation(id: Int) async {
        guard actingInvitationID == nil,
              invitations.contains(where: { $0.id == id }) else { return }

        actingInvitationID = id
        actionErrorMessage = nil
        defer { actingInvitationID = nil }

        do {
            _ = try await declineAction(id)
            invitations.removeAll { $0.id == id }
            updateContentState()
        } catch is CancellationError {
            return
        } catch {
            actionErrorMessage = error.localizedDescription
        }
    }

    func dismissActionError() {
        actionErrorMessage = nil
    }

    func reset() {
        invitations = []
        actingInvitationID = nil
        actionErrorMessage = nil
        state = .idle
    }

    private func updateContentState() {
        state = invitations.isEmpty ? .empty : .content
    }
}
