//
//  PharmacistDetailView.swift
//  Medsy-Pharmacy
//
//  Pharmacist Detail Screen
//

import SwiftUI

struct PharmacistDetailView: View {
    let member: PharmacistMember
    let canEdit: Bool
    let canRemove: Bool
    let onEdit: () -> Void
    let onRemove: () -> Void
    let onBack: () -> Void

    var body: some View {
        ZStack {
            PharmacyColor.bg.ignoresSafeArea()
            
            VStack(spacing: 0) {
                header
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: PharmacySpacing.lg) {
                        pharmacistInfoCard
                        
                        if canEdit || canRemove {
                            actionsSection
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
            
            Text("profile.user_profile".localized)
                .font(PharmacyColor.sans(17, .bold))
                .foregroundStyle(PharmacyColor.textPrimary)
                .frame(maxWidth: .infinity)
            
            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.horizontal, PharmacySpacing.md)
        .padding(.vertical, PharmacySpacing.sm)
    }
    
    private var pharmacistInfoCard: some View {
        VStack(spacing: PharmacySpacing.md) {
            PharmacistAvatarView(pharmacist: member.toPharmacist(), diameter: 80)
            
            VStack(spacing: PharmacySpacing.xxs) {
                HStack(spacing: PharmacySpacing.xxs) {
                    Text(member.fullName)
                        .font(PharmacyColor.sans(20, .bold))
                        .foregroundStyle(PharmacyColor.textPrimary)
                    if member.isAdmin {
                        PillBadge(text: "pharmacy_team.admin_badge".localized)
                    }
                }
                Text("profile.role_pharmacist".localized)
                    .font(PharmacyColor.sans(14))
                    .foregroundStyle(PharmacyColor.textSecondary)
            }
            
            infoRow(icon: "envelope.fill", title: "profile.email".localized, value: member.email)
            infoRow(icon: "phone.fill", title: "profile.phone".localized, value: member.phoneNumber)
        }
        .padding(PharmacySpacing.lg)
        .background(PharmacyColor.card, in: RoundedRectangle(cornerRadius: PharmacyRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: PharmacyRadius.lg)
                .stroke(PharmacyColor.border, lineWidth: 1)
        )
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
        .padding(PharmacySpacing.md)
        .background(PharmacyColor.card, in: RoundedRectangle(cornerRadius: PharmacyRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: PharmacyRadius.lg)
                .stroke(PharmacyColor.border, lineWidth: 1)
        )
    }
    
    @ViewBuilder
    private var actionsSection: some View {
        VStack(spacing: PharmacySpacing.sm) {
            if canEdit {
                Button {
                    onEdit()
                } label: {
                    HStack(spacing: PharmacySpacing.sm) {
                        Image(systemName: "pencil")
                            .font(.system(size: 16, weight: .semibold))
                        Text("pharmacy_team.edit".localized)
                    }
                    .font(PharmacyColor.sans(15, .semibold))
                    .foregroundStyle(PharmacyColor.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(PharmacyColor.primary.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(.plain)
            }
            
            if canRemove {
                Button {
                    onRemove()
                } label: {
                    HStack(spacing: PharmacySpacing.sm) {
                        Image(systemName: "trash")
                            .font(.system(size: 16, weight: .semibold))
                        Text("pharmacy_team.remove".localized)
                    }
                    .font(PharmacyColor.sans(15, .semibold))
                    .foregroundStyle(PharmacyColor.danger)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(PharmacyColor.danger.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    PharmacistDetailView(
        member: PharmacistMember(
            id: 1,
            firstName: "Ahmed",
            lastName: "Mohamed",
            email: "ahmed@example.com",
            phoneNumber: "010 1234 5678",
            isAdmin: false
        ),
        canEdit: true,
        canRemove: true,
        onEdit: {},
        onRemove: {},
        onBack: {}
    )
}
