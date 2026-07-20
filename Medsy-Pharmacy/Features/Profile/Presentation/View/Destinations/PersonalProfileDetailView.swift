//
//  PersonalProfileDetailView.swift
//  Medsy-Pharmacy
//
//  Personal Profile Detail Screen
//

import SwiftUI

struct PersonalProfileDetailView: View {
    let profile: PharmacyProfile?
    let onBack: () -> Void

    var body: some View {
        ZStack {
            PharmacyColor.bg.ignoresSafeArea()
            
            VStack(spacing: 0) {
                header
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: PharmacySpacing.lg) {
                        if let profile {
                            profileInfoCard(profile: profile)
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
            
            Text("profile.personal_data".localized)
                .font(PharmacyColor.sans(17, .bold))
                .foregroundStyle(PharmacyColor.textPrimary)
                .frame(maxWidth: .infinity)
            
            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.horizontal, PharmacySpacing.md)
        .padding(.vertical, PharmacySpacing.sm)
    }
    
    private func profileInfoCard(profile: PharmacyProfile) -> some View {
        VStack(spacing: PharmacySpacing.md) {
            PharmacistAvatarView(pharmacist: profile.toPharmacist(), diameter: 80)
            
            VStack(spacing: PharmacySpacing.xxs) {
                Text(profile.fullName)
                    .font(PharmacyColor.sans(20, .bold))
                    .foregroundStyle(PharmacyColor.textPrimary)
                Text(profile.email)
                    .font(PharmacyColor.sans(14))
                    .foregroundStyle(PharmacyColor.textSecondary)
            }
            
            infoRow(icon: "phone.fill", title: "profile.phone".localized, value: profile.phoneNumber)
            
            if let homeAddress = profile.homeAddress {
                infoRow(icon: "house.fill", title: "profile.home_address".localized, value: homeAddress)
            }
            
            if let dateOfBirth = profile.dateOfBirth {
                infoRow(icon: "calendar.fill", title: "profile.date_of_birth".localized, value: formatDate(dateOfBirth))
            }
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
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale.current
        return formatter.string(from: date)
    }
}

#Preview {
    PersonalProfileDetailView(profile: PharmacyProfile.preview, onBack: {})
}
