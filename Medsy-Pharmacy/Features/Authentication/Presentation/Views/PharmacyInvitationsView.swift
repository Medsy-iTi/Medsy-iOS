import SwiftUI

struct PharmacyInvitationsView: View {
    @State private var viewModel: PharmacyInvitationsViewModel
    let onAccept: (Int) -> Void
    let onDecline: (Int) -> Void

    init(
        viewModel: PharmacyInvitationsViewModel,
        onAccept: @escaping (Int) -> Void,
        onDecline: @escaping (Int) -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onAccept = onAccept
        self.onDecline = onDecline
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                loadingView
            case .content:
                invitationList
            case .empty:
                emptyView
            case let .error(message):
                errorView(message: message)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(PharmacyColor.bg.ignoresSafeArea())
        .navigationTitle("pharmacy.invitations.title".localized)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.load()
        }
        .alert(
            "common.error".localized,
            isPresented: Binding(
                get: { viewModel.actionErrorMessage != nil },
                set: { if !$0 { viewModel.dismissActionError() } }
            )
        ) {
            Button("common.ok".localized) { viewModel.dismissActionError() }
        } message: {
            Text(viewModel.actionErrorMessage ?? "")
        }
    }

    private var invitationList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: PharmacySpacing.md) {
                Text("pharmacy.invitations.subtitle".localized)
                    .font(PharmacyColor.sans(14))
                    .foregroundStyle(PharmacyColor.textSecondary)

                ForEach(viewModel.invitations) { invitation in
                    PharmacyInvitationCard(
                        invitation: invitation,
                        isActing: viewModel.actingInvitationID == invitation.id,
                        actionsDisabled: viewModel.actingInvitationID != nil,
                        onAccept: { onAccept(invitation.id) },
                        onDecline: { onDecline(invitation.id) }
                    )
                }
            }
            .padding(PharmacySpacing.md)
        }
        .refreshable {
            await viewModel.load(force: true)
        }
    }

    private var loadingView: some View {
        VStack(spacing: PharmacySpacing.sm) {
            ProgressView()
                .tint(PharmacyColor.primary)
            Text("pharmacy.invitations.loading".localized)
                .font(PharmacyColor.sans(14))
                .foregroundStyle(PharmacyColor.textSecondary)
        }
    }

    private var emptyView: some View {
        VStack(spacing: PharmacySpacing.md) {
            Image(systemName: "bell.slash")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(PharmacyColor.primary)
                .frame(width: 84, height: 84)
                .background(PharmacyColor.primarySoft, in: Circle())

            Text("pharmacy.invitations.empty.title".localized)
                .font(PharmacyColor.sans(20, .bold))
                .foregroundStyle(PharmacyColor.textPrimary)

            Text("pharmacy.invitations.empty.message".localized)
                .font(PharmacyColor.sans(14))
                .foregroundStyle(PharmacyColor.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(PharmacySpacing.xl)
        .pharmacyCard(padding: nil, elevation: .subtle)
        .padding(PharmacySpacing.md)
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: PharmacySpacing.md) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 32))
                .foregroundStyle(PharmacyColor.warning)

            Text("pharmacy.invitations.error.title".localized)
                .font(PharmacyColor.sans(20, .bold))
                .foregroundStyle(PharmacyColor.textPrimary)

            Text(message)
                .font(PharmacyColor.sans(14))
                .foregroundStyle(PharmacyColor.textSecondary)
                .multilineTextAlignment(.center)

            PharmacyPrimaryButton(
                title: "common.retry".localized,
                style: .soft,
                action: { Task { await viewModel.load(force: true) } }
            )
            .frame(maxWidth: 260)
        }
        .padding(PharmacySpacing.xl)
        .pharmacyCard(padding: nil, elevation: .subtle)
        .padding(PharmacySpacing.md)
    }
}
