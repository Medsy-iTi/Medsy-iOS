//
//  UserProfileView.swift
//  Medsy-Pharmacy
//
//  User Profile Component with modern design
//

import SwiftUI

struct UserProfileView: View {
    let profile: PharmacyProfile
    let onEdit: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: PharmacySpacing.md) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: PharmacySpacing.xs) {
                    Text("profile.user_profile".localized)
                        .font(PharmacyColor.sans(14, .semibold))
                        .foregroundStyle(PharmacyColor.textSecondary)
                    
                    HStack(spacing: PharmacySpacing.sm) {
                        // Avatar
                        ZStack {
                            Circle()
                                .fill(PharmacyColor.primary.opacity(0.12))
                                .frame(width: 64, height: 64)
                            
                            Text(profile.fullName.prefix(1).uppercased())
                                .font(PharmacyColor.sans(28, .bold))
                                .foregroundStyle(PharmacyColor.primary)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 4) {
                                Text(profile.fullName)
                                    .font(PharmacyColor.sans(18, .bold))
                                    .foregroundStyle(PharmacyColor.textPrimary)
                                
                                if profile.isPharmacyAdmin {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 14))
                                        .foregroundStyle(PharmacyColor.warning)
                                }
                            }
                            
                            Text(profile.email)
                                .font(PharmacyColor.sans(13, .medium))
                                .foregroundStyle(PharmacyColor.textSecondary)
                        }
                    }
                }
                
                Spacer()
                
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(PharmacyColor.primary)
                        .frame(width: 40, height: 40)
                        .background(PharmacyColor.primary.opacity(0.1))
                        .clipShape(Circle())
                }
                .accessibilityLabel("profile.edit.title".localized)
            }
            .padding(PharmacySpacing.md)
            
            // Details Section
            VStack(spacing: PharmacySpacing.sm) {
                profileDetailRow(
                    icon: "phone.fill",
                    title: "profile.phone".localized,
                    value: profile.phoneNumber
                )
                
                if let address = profile.homeAddress, !address.isEmpty {
                    profileDetailRow(
                        icon: "mappin.and.ellipse",
                        title: "profile.home_address".localized,
                        value: address
                    )
                }
                
                if let dob = profile.dateOfBirth {
                    profileDetailRow(
                        icon: "calendar",
                        title: "profile.date_of_birth".localized,
                        value: formatDate(dob)
                    )
                }
            }
            .padding(.horizontal, PharmacySpacing.md)
            .padding(.bottom, PharmacySpacing.md)
        }
        .pharmacyCard(padding: nil, elevation: .subtle)
    }
    
    private func profileDetailRow(icon: String, title: String, value: String) -> some View {
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
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

#Preview {
    UserProfileView(
        profile: PharmacyProfile.preview,
        onEdit: {}
    )
    .padding()
    .background(PharmacyColor.bg)
}
