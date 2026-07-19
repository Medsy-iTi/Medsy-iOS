//
//  PharmacyManagementView.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

import SwiftUI

struct PharmacyManagementView: View {
    let state: PharmacyManagementViewState
    let onAddPharmacy: () -> Void
    let onEditPharmacy: (PharmacyManagementDisplayModel) -> Void
    let onDeletePharmacy: (PharmacyManagementDisplayModel) -> Void
    let onRetry: () -> Void
    @State private var pharmacyPendingDeletion: PharmacyManagementDisplayModel?

    var body: some View {
        Group {
            switch state {
            case .loading:
                loadingView
            case .unassigned:
                PharmacyManagementStateView(
                    icon: "cross.case.fill",
                    title: "pharmacy.management.empty.title".localized,
                    message: "pharmacy.management.empty.message".localized,
                    actionTitle: "pharmacy.management.add".localized,
                    action: onAddPharmacy
                )
            case let .assigned(pharmacy):
                assignedView(pharmacy)
            case .failure:
                PharmacyManagementStateView(
                    icon: "wifi.exclamationmark",
                    title: "pharmacy.management.error.title".localized,
                    message: "pharmacy.management.error.message".localized,
                    actionTitle: "pharmacy.management.retry".localized,
                    action: onRetry
                )
            }
        }
        .background(PharmacyColor.bg.ignoresSafeArea())
        .alert(
            "pharmacy.management.delete.confirm.title".localized,
            isPresented: deletionAlertBinding,
            presenting: pharmacyPendingDeletion
        ) { pharmacy in
            Button("pharmacy.management.delete.confirm.action".localized, role: .destructive) {
                onDeletePharmacy(pharmacy)
                pharmacyPendingDeletion = nil
            }
            Button("pharmacy.management.delete.confirm.cancel".localized, role: .cancel) {
                pharmacyPendingDeletion = nil
            }
        } message: { _ in
            Text("pharmacy.management.delete.confirm.message".localized)
        }
    }

    private var loadingView: some View {
        VStack(spacing: PharmacySpacing.md) {
            ProgressView()
                .tint(PharmacyColor.primary)
                .scaleEffect(1.2)

            Text("pharmacy.management.loading".localized)
                .font(PharmacyColor.sans(14, .medium))
                .foregroundStyle(PharmacyColor.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func assignedView(_ pharmacy: PharmacyManagementDisplayModel) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: PharmacySpacing.lg) {
                PharmacyManagementHeader(
                    title: "pharmacy.management.title".localized,
                    subtitle: pharmacy.isAdmin
                        ? "pharmacy.management.admin.subtitle".localized
                        : "pharmacy.management.member.subtitle".localized
                )

                PharmacyInformationCard(pharmacy: pharmacy)
                PharmacyTeamCard(members: pharmacy.pharmacists)

                if pharmacy.isAdmin {
                    PharmacyPrimaryButton(
                        title: "pharmacy.management.edit".localized,
                        systemImage: "pencil",
                        action: { onEditPharmacy(pharmacy) }
                    )

                    Button {
                        pharmacyPendingDeletion = pharmacy
                    } label: {
                        Label("pharmacy.management.delete".localized, systemImage: "trash")
                            .font(PharmacyColor.sans(15, .bold))
                            .foregroundStyle(PharmacyColor.danger)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(PharmacyColor.danger.opacity(0.08), in: RoundedRectangle(cornerRadius: PharmacyRadius.lg))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, PharmacySpacing.md)
            .padding(.top, PharmacySpacing.md)
            .padding(.bottom, PharmacySpacing.xl)
        }
    }

    private var deletionAlertBinding: Binding<Bool> {
        Binding(
            get: { pharmacyPendingDeletion != nil },
            set: { isPresented in
                if !isPresented {
                    pharmacyPendingDeletion = nil
                }
            }
        )
    }
}

#Preview("Unassigned") {
    PharmacyManagementView(
        state: .unassigned,
        onAddPharmacy: {},
        onEditPharmacy: { _ in },
        onDeletePharmacy: { _ in },
        onRetry: {}
    )
    .environment(LanguageManager.shared)
    .pharmacyLocalizedEnvironment()
}

#Preview("Admin") {
    PharmacyManagementView(
        state: .assigned(
            PharmacyManagementDisplayModel(
                id: 1,
                name: "El Nozha Pharmacy",
                address: "El Nile Street, Maadi, Cairo",
                phoneNumber: "010 1234 5678",
                latitude: 30.04442,
                longitude: 31.23571,
                isAdmin: true,
                pharmacists: [
                    PharmacyTeamMemberDisplayModel(
                        id: 1,
                        fullName: "Ahmed Elkady",
                        phoneNumber: "010 1234 5678",
                        email: "ahmed@example.com",
                        isAdmin: true
                    )
                ]
            )
        ),
        onAddPharmacy: {},
        onEditPharmacy: { _ in },
        onDeletePharmacy: { _ in },
        onRetry: {}
    )
    .environment(LanguageManager.shared)
    .pharmacyLocalizedEnvironment()
}
