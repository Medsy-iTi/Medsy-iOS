//
//  PharmacyProfileView.swift
//  Medsy-Pharmacy
//
//  Pharmacy Profile Component with modern design
//

import SwiftUI

struct PharmacyProfileView: View {
    let profile: PharmacyProfile
    let onEdit: (() -> Void)?
    let onInvite: (() -> Void)?
    let onLeave: (() -> Void)?
    let onDelete: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: PharmacySpacing.md) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: PharmacySpacing.xs) {
                    Text("profile.pharmacy_profile".localized)
                        .font(PharmacyColor.sans(14, .semibold))
                        .foregroundStyle(PharmacyColor.textSecondary)
                    
                    HStack(spacing: PharmacySpacing.sm) {
                        // Pharmacy Icon
                        ZStack {
                            RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous)
                                .fill(PharmacyColor.primary.opacity(0.12))
                                .frame(width: 64, height: 64)
                            
                            Image(systemName: "building.2.fill")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundStyle(PharmacyColor.primary)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(profile.pharmacyName ?? "pharmacy_card.unknown".localized)
                                .font(PharmacyColor.sans(18, .bold))
                                .foregroundStyle(PharmacyColor.textPrimary)
                            
                            Text("pharmacy_card.your_pharmacy".localized)
                                .font(PharmacyColor.sans(13, .medium))
                                .foregroundStyle(PharmacyColor.textSecondary)
                        }
                    }
                }
                
                Spacer()
                
                if let onEdit {
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(PharmacyColor.primary)
                            .frame(width: 40, height: 40)
                            .background(PharmacyColor.primary.opacity(0.1))
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("pharmacy_card.edit".localized)
                }
            }
            .padding(PharmacySpacing.md)
            
            // Details Section
            VStack(spacing: PharmacySpacing.sm) {
                if let address = profile.pharmacyAddress, !address.isEmpty {
                    pharmacyDetailRow(
                        icon: "mappin.and.ellipse",
                        title: "pharmacy_edit.address".localized,
                        value: address
                    )
                }
                
                if let phone = profile.pharmacyPhoneNumber, !phone.isEmpty {
                    pharmacyDetailRow(
                        icon: "phone.fill",
                        title: "pharmacy_edit.phone".localized,
                        value: phone
                    )
                }
                
                // Team count
                pharmacyDetailRow(
                    icon: "person.2.fill",
                    title: "pharmacy_team.title".localized,
                    value: String(format: "profile.pharmacists_count".localized, profile.pharmacyMembers.count)
                )
            }
            .padding(.horizontal, PharmacySpacing.md)
            
            // Admin Actions
            if profile.isPharmacyAdmin {
                Divider()
                    .overlay(PharmacyColor.border)
                    .padding(.horizontal, PharmacySpacing.md)
                
                VStack(spacing: PharmacySpacing.sm) {
                    if let onInvite {
                        Button(action: onInvite) {
                            HStack(spacing: PharmacySpacing.sm) {
                                Image(systemName: "person.badge.plus")
                                    .font(.system(size: 14, weight: .semibold))
                                Text("pharmacy_team.invite".localized)
                                    .font(PharmacyColor.sans(14, .semibold))
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .semibold))
                            }
                            .foregroundStyle(PharmacyColor.primary)
                            .padding(.horizontal, PharmacySpacing.md)
                            .padding(.vertical, PharmacySpacing.sm)
                            .background(PharmacyColor.primary.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: PharmacyRadius.sm, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                    
                    if let onDelete {
                        Button(role: .destructive, action: onDelete) {
                            HStack(spacing: PharmacySpacing.sm) {
                                Image(systemName: "trash")
                                    .font(.system(size: 14, weight: .semibold))
                                Text("pharmacy_card.delete".localized)
                                    .font(PharmacyColor.sans(14, .semibold))
                            }
                            .foregroundStyle(PharmacyColor.danger)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, PharmacySpacing.sm)
                            .background(PharmacyColor.danger.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: PharmacyRadius.sm, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, PharmacySpacing.md)
                .padding(.bottom, PharmacySpacing.md)
            } else if let onLeave {
                Divider()
                    .overlay(PharmacyColor.border)
                    .padding(.horizontal, PharmacySpacing.md)
                
                Button(role: .destructive, action: onLeave) {
                    HStack(spacing: PharmacySpacing.sm) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 14, weight: .semibold))
                        Text("pharmacy_card.leave".localized)
                            .font(PharmacyColor.sans(14, .semibold))
                    }
                    .foregroundStyle(PharmacyColor.danger)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, PharmacySpacing.sm)
                    .background(PharmacyColor.danger.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: PharmacyRadius.sm, style: .continuous))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, PharmacySpacing.md)
                .padding(.bottom, PharmacySpacing.md)
            } else {
                Color.clear
                    .frame(height: PharmacySpacing.md)
            }
        }
        .background(PharmacyColor.card)
        .clipShape(RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous)
                .stroke(PharmacyColor.border, lineWidth: 1)
        )
    }
    
    private func pharmacyDetailRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: PharmacySpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(PharmacyColor.primary)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(PharmacyColor.sans(12, .medium))
                    .foregroundStyle(PharmacyColor.textSecondary)
                
                Text(value)
                    .font(PharmacyColor.sans(14, .semibold))
                    .foregroundStyle(PharmacyColor.textPrimary)
            }
            
            Spacer()
        }
        .padding(.vertical, PharmacySpacing.xs)
    }
}

#Preview {
    VStack(spacing: PharmacySpacing.md) {
        PharmacyProfileView(
            profile: PharmacyProfile.preview,
            onEdit: {},
            onInvite: {},
            onLeave: nil,
            onDelete: {}
        )
        
        PharmacyProfileView(
            profile: PharmacyProfile(
                id: "2",
                firstName: "John",
                lastName: "Doe",
                email: "john@example.com",
                phoneNumber: "010 1234 5678",
                pharmacyId: 1,
                isPharmacyAdmin: false,
                homeAddress: nil,
                dateOfBirth: nil,
                pharmacyName: "Test Pharmacy",
                pharmacyAddress: "123 Main St",
                pharmacyPhoneNumber: "010 9876 5432",
                pharmacyMembers: []
            ),
            onEdit: nil,
            onInvite: nil,
            onLeave: {},
            onDelete: nil
        )
    }
    .padding()
    .background(PharmacyColor.bg)
}
