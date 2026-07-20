//
//  InviteSuccessView.swift
//  Medsy-Pharmacy
//
//  Invite Success Screen
//

import SwiftUI

struct InviteSuccessView: View {
    let info: InviteSuccessInfo
    let onBack: () -> Void

    var body: some View {
        ZStack {
            PharmacyColor.bg.ignoresSafeArea()
            
            VStack(spacing: 0) {
                header
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: PharmacySpacing.xl) {
                        successIcon
                        
                        VStack(spacing: PharmacySpacing.sm) {
                            Text("pharmacy_team.invite_success_title".localized)
                                .font(PharmacyColor.sans(20, .bold))
                                .foregroundStyle(PharmacyColor.textPrimary)
                            
                            Text("pharmacy_team.invite_success_subtitle".localized)
                                .font(PharmacyColor.sans(14))
                                .foregroundStyle(PharmacyColor.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        
                        invitedEmailCard
                        
                        Button {
                            onBack()
                        } label: {
                            Text("pharmacy_team.back_to_profile".localized)
                                .font(PharmacyColor.sans(15, .semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(PharmacyColor.primary)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, PharmacySpacing.md)
                    .padding(.top, PharmacySpacing.xl)
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
            
            Text("pharmacy_team.invite_header".localized)
                .font(PharmacyColor.sans(17, .bold))
                .foregroundStyle(PharmacyColor.textPrimary)
                .frame(maxWidth: .infinity)
            
            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.horizontal, PharmacySpacing.md)
        .padding(.vertical, PharmacySpacing.sm)
    }
    
    private var successIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous)
                .fill(PharmacyColor.successSoft)
                .frame(width: 80, height: 80)
            Image(systemName: "checkmark")
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(PharmacyColor.success)
        }
    }
    
    private var invitedEmailCard: some View {
        VStack(spacing: PharmacySpacing.sm) {
            Text("pharmacy_team.invite_email".localized)
                .font(PharmacyColor.sans(13, .semibold))
                .foregroundStyle(PharmacyColor.textSecondary)
            
            Text(info.email)
                .font(PharmacyColor.sans(16, .semibold))
                .foregroundStyle(PharmacyColor.textPrimary)
            
            HStack(spacing: PharmacySpacing.xxs) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(PharmacyColor.textSecondary)
                Text("pharmacy_team.invite_pending".localized)
                    .font(PharmacyColor.sans(12))
                    .foregroundStyle(PharmacyColor.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(PharmacySpacing.lg)
        .background(PharmacyColor.card, in: RoundedRectangle(cornerRadius: PharmacyRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: PharmacyRadius.lg)
                .stroke(PharmacyColor.border, lineWidth: 1)
        )
    }
}

