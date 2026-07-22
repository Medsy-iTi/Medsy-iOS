//
//  PharmacistsListView.swift
//  Medsy-Pharmacy
//
//  Pharmacists List Screen
//

import SwiftUI

struct PharmacistsListView: View {
    let members: [PharmacistMember]
    let isAdmin: Bool
    let isInviting: Bool
    let inviteErrorMessage: String?
    let onInvite: () -> Void
    let onDismissError: () -> Void
    let onMemberTap: (PharmacistMember) -> Void
    let onBack: () -> Void

    var body: some View {
        ZStack {
            PharmacyColor.bg.ignoresSafeArea()
            
            VStack(spacing: 0) {
                header
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: PharmacySpacing.lg) {
                        if members.isEmpty {
                            emptyState
                        } else {
                            membersList
                        }
                        
                        if isAdmin {
                            inviteButton
                        }
                        
                        if let inviteErrorMessage {
                            errorCard(inviteErrorMessage)
                        }
                    }
                    .padding(.horizontal, PharmacySpacing.md)
                    .padding(.top, PharmacySpacing.sm)
                    .padding(.bottom, PharmacySpacing.xl)
                }
            }
        }
    }
    
    private var header: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.backward")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(PharmacyColor.textPrimary)
                    .frame(width: 36, height: 36)
                    .background(PharmacyColor.surface)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            
            Text("pharmacy_team.menu_title".localized)
                .font(PharmacyColor.sans(17, .bold))
                .foregroundStyle(PharmacyColor.textPrimary)
                .frame(maxWidth: .infinity)
            
            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.horizontal, PharmacySpacing.md)
        .padding(.vertical, PharmacySpacing.sm)
    }
    
    @ViewBuilder
    private var emptyState: some View {
        VStack(spacing: PharmacySpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous)
                    .fill(PharmacyColor.primary.opacity(0.12))
                    .frame(width: 72, height: 72)
                Image(systemName: "person.2")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(PharmacyColor.primary)
            }
            
            Text("pharmacy_team.empty".localized)
                .font(PharmacyColor.sans(15, .medium))
                .foregroundStyle(PharmacyColor.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, PharmacySpacing.xl)
    }
    
    private var membersList: some View {
        VStack(spacing: PharmacySpacing.sm) {
            Text(String(format: "pharmacy_team.section_header".localized, members.count))
                .font(PharmacyColor.sans(14, .semibold))
                .foregroundStyle(PharmacyColor.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: PharmacySpacing.sm) {
                ForEach(members) { member in
                    Button {
                        onMemberTap(member)
                    } label: {
                        PharmacistRow(member: member)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    private var inviteButton: some View {
        Button {
            onInvite()
        } label: {
            HStack(spacing: PharmacySpacing.sm) {
                if isInviting {
                    ProgressView().tint(.white)
                } else {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 16, weight: .semibold))
                    Text("pharmacy_team.invite".localized)
                }
            }
            .font(PharmacyColor.sans(15, .semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(isInviting ? PharmacyColor.primary.opacity(0.72) : PharmacyColor.primary)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(isInviting)
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

private struct PharmacistRow: View {
    let member: PharmacistMember

    var body: some View {
        HStack(spacing: PharmacySpacing.sm) {
            PharmacistAvatarView(pharmacist: member.toPharmacist(), diameter: 48)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: PharmacySpacing.xxs) {
                    Text(member.fullName)
                        .font(PharmacyColor.sans(15, .semibold))
                        .foregroundStyle(PharmacyColor.textPrimary)
                    if member.isAdmin {
                        PillBadge(text: "pharmacy_team.admin_badge".localized)
                    }
                }
                Text("profile.role_pharmacist".localized)
                    .font(PharmacyColor.sans(13))
                    .foregroundStyle(PharmacyColor.textSecondary)
                Text(member.email)
                    .font(PharmacyColor.sans(12))
                    .foregroundStyle(PharmacyColor.textSecondary)
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.backward")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(PharmacyColor.textSecondary)
                .flipsForRightToLeftLayoutDirection(true)
        }
        .padding(PharmacySpacing.md)
        .background(PharmacyColor.card, in: RoundedRectangle(cornerRadius: PharmacyRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: PharmacyRadius.lg)
                .stroke(PharmacyColor.border, lineWidth: 1)
        )
    }
}

#Preview {
    PharmacistsListView(
        members: [
            PharmacistMember(
                id: 1,
                firstName: "Ahmed",
                lastName: "Mohamed",
                email: "ahmed@example.com",
                phoneNumber: "010 1234 5678",
                isAdmin: true
            ),
            PharmacistMember(
                id: 2,
                firstName: "Mona",
                lastName: "Mahmoud",
                email: "mona@example.com",
                phoneNumber: "011 2345 6789",
                isAdmin: false
            )
        ],
        isAdmin: true,
        isInviting: false,
        inviteErrorMessage: nil,
        onInvite: {},
        onDismissError: {},
        onMemberTap: { _ in },
        onBack: {}
    )
}
