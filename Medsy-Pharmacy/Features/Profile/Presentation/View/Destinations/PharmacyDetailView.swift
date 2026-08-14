//
//  PharmacyDetailView.swift
//  Medsy-Pharmacy
//
//  Pharmacy Detail Screen
//

import SwiftUI

struct PharmacyDetailView: View {
    let pharmacy: PharmacySummary
    let isAdmin: Bool
    let isDeleting: Bool
    let isLeaving: Bool
    let deleteErrorMessage: String?
    let leaveErrorMessage: String?
    let pendingInvitations: [PharmacyInvitation]
    let isLoadingPendingInvitations: Bool
    let pendingInvitationDeletingId: Int?
    let pendingInvitationsErrorMessage: String?
    let onLoadPendingInvitations: () -> Void
    let onRefreshPendingInvitations: () -> Void
    let onInvitationTap: (PharmacyInvitation) -> Void
    let onDeleteInvitation: (PharmacyInvitation) async -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onLeave: () -> Void
    let onDismissError: () -> Void
    
    @State private var showDeleteConfirmation = false
    @State private var showLeaveConfirmation = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: PharmacySpacing.lg) {
                pharmacyInfoCard

                if isAdmin {
                    adminActions
                    PendingInvitationsSectionView(
                        invitations: pendingInvitations,
                        isLoading: isLoadingPendingInvitations,
                        deletingInvitationId: pendingInvitationDeletingId,
                        errorMessage: pendingInvitationsErrorMessage,
                        onRefresh: onRefreshPendingInvitations,
                        onInvitationTap: onInvitationTap,
                        onDeleteInvitation: onDeleteInvitation
                    )
                } else {
                    leaveAction
                }

                if let deleteErrorMessage {
                    errorCard(deleteErrorMessage)
                }

                if let leaveErrorMessage {
                    errorCard(leaveErrorMessage)
                }
            }
            .padding(.horizontal, PharmacySpacing.md)
            .padding(.vertical, PharmacySpacing.md)
        }
        .background(PharmacyColor.bg.ignoresSafeArea())
        .navigationTitle("pharmacy_details_title".localized)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if isAdmin {
                onLoadPendingInvitations()
            }
        }
        .confirmationDialog(
            "pharmacy_card.delete_confirm_title".localized,
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("pharmacy_card.delete_confirm_action".localized, role: .destructive) {
                onDelete()
            }
            Button("cancel".localized, role: .cancel) {}
        } message: {
            Text("pharmacy_card.delete_confirm_message".localized)
        }
        .confirmationDialog(
            "pharmacy_card.leave_confirm_title".localized,
            isPresented: $showLeaveConfirmation,
            titleVisibility: .visible
        ) {
            Button("pharmacy_card.leave_confirm_action".localized, role: .destructive) {
                onLeave()
            }
            Button("cancel".localized, role: .cancel) {}
        } message: {
            Text("pharmacy_card.leave_confirm_message".localized)
        }
    }
    
    private var pharmacyInfoCard: some View {
        VStack(spacing: PharmacySpacing.md) {
            HStack(spacing: PharmacySpacing.md) {
                ZStack {
                    Circle().fill(PharmacyColor.primary)
                    Image(systemName: "cross.case.fill")
                        .foregroundStyle(.white)
                        .font(.system(size: 24, weight: .semibold))
                }
                .frame(width: 64, height: 64)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: PharmacySpacing.xxs) {
                        Text(pharmacy.name)
                            .font(PharmacyColor.sans(18, .bold))
                            .foregroundStyle(PharmacyColor.textPrimary)
                        if pharmacy.isVerified {
                            VerifiedBadgeIcon(size: 16)
                        }
                    }
                    Text(pharmacy.address)
                        .font(PharmacyColor.sans(14))
                        .foregroundStyle(PharmacyColor.textSecondary)
                }
                
                Spacer(minLength: 0)
            }
            .pharmacyCard(elevation: .raised)
            
            infoRow(
                icon: "phone.fill",
                title: "phone_number_title".localized,
                value: pharmacy.phoneNumber
            )
        }
    }
    
    private func infoRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: PharmacySpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: PharmacyRadius.sm)
                    .fill(PharmacyColor.primary.opacity(0.12))
                Image(systemName: icon)
                    .foregroundStyle(PharmacyColor.primary)
                    .font(.system(size: 14, weight: .semibold))
            }
            .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(PharmacyColor.sans(12, .medium))
                    .foregroundStyle(PharmacyColor.textSecondary)
                Text(value)
                    .font(PharmacyColor.sans(15, .semibold))
                    .foregroundStyle(PharmacyColor.textPrimary)
            }
            
            Spacer(minLength: 0)
        }
        .pharmacyCard(elevation: .subtle)
    }
    
    @ViewBuilder
    private var adminActions: some View {
        VStack(spacing: PharmacySpacing.sm) {
            Button {
                onEdit()
            } label: {
                HStack(spacing: PharmacySpacing.sm) {
                    Image(systemName: "pencil")
                        .font(.system(size: 16, weight: .semibold))
                    Text("pharmacy_card.edit".localized)
                }
                .font(PharmacyColor.sans(15, .semibold))
                .foregroundStyle(PharmacyColor.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(PharmacyColor.primary.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(PharmacyPressableButtonStyle())
            
            Button {
                showDeleteConfirmation = true
            } label: {
                HStack(spacing: PharmacySpacing.sm) {
                    if isDeleting {
                        ProgressView().tint(PharmacyColor.danger)
                    } else {
                        Image(systemName: "trash")
                            .font(.system(size: 16, weight: .semibold))
                        Text("pharmacy_card.delete".localized)
                    }
                }
                .font(PharmacyColor.sans(15, .semibold))
                .foregroundStyle(isDeleting ? .white : PharmacyColor.danger)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(isDeleting ? PharmacyColor.danger.opacity(0.72) : PharmacyColor.danger.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(PharmacyPressableButtonStyle())
            .disabled(isDeleting)
        }
    }
    
    @ViewBuilder
    private var leaveAction: some View {
        Button {
            showLeaveConfirmation = true
        } label: {
            HStack(spacing: PharmacySpacing.sm) {
                if isLeaving {
                    ProgressView().tint(PharmacyColor.danger)
                } else {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 16, weight: .semibold))
                    Text("pharmacy_card.leave".localized)
                }
            }
            .font(PharmacyColor.sans(15, .semibold))
            .foregroundStyle(isLeaving ? .white : PharmacyColor.danger)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(isLeaving ? PharmacyColor.danger.opacity(0.72) : PharmacyColor.danger.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(PharmacyPressableButtonStyle())
        .disabled(isLeaving)
    }
    
    private func errorCard(_ message: String) -> some View {
        HStack(spacing: PharmacySpacing.sm) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(PharmacyColor.danger)
            Text(message)
                .font(PharmacyColor.sans(13, .medium))
                .foregroundStyle(PharmacyColor.danger)
            Spacer(minLength: 0)
            Button {
                onDismissError()
            } label: {
                Image(systemName: "xmark")
                    .foregroundStyle(PharmacyColor.danger)
            }
            .buttonStyle(.plain)
        }
        .padding(PharmacySpacing.md)
        .background(PharmacyColor.danger.opacity(0.1), in: RoundedRectangle(cornerRadius: PharmacyRadius.md))
    }
}
