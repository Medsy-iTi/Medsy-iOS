//
//  InvitePharmacistView.swift
//  Medsy-Pharmacy
//
//  Invite Pharmacist Screen
//

import SwiftUI

struct InvitePharmacistView: View {
    let pharmacyName: String
    let isInviting: Bool
    let errorMessage: String?
    let onCancel: () -> Void
    let onInvite: (String) async -> Bool
    
    @State private var email: String = ""
    @State private var validationError: String?
    
    var body: some View {
        ZStack {
            PharmacyColor.bg.ignoresSafeArea()
            
            VStack(spacing: 0) {
                header
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: PharmacySpacing.lg) {
                        iconBlock
                        
                        VStack(alignment: .leading, spacing: PharmacySpacing.sm) {
                            Text("pharmacy_team.invite_title".localized)
                                .font(PharmacyColor.sans(16, .bold))
                                .foregroundStyle(PharmacyColor.textPrimary)
                            
                            Text(String(format: "pharmacy_team.invite_subtitle".localized, pharmacyName))
                                .font(PharmacyColor.sans(13, .medium))
                                .foregroundStyle(PharmacyColor.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        emailField
                        validationBlock
                        errorBlock
                        inviteButton
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
            Button(action: onCancel) {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .bold))
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
    
    private var iconBlock: some View {
        VStack(spacing: PharmacySpacing.sm) {
            ZStack {
                RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous)
                    .fill(PharmacyColor.primary.opacity(0.12))
                    .frame(width: 72, height: 72)
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(PharmacyColor.primary)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private var emailField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("pharmacy_team.invite_email".localized)
                .font(PharmacyColor.sans(13, .semibold))
                .foregroundStyle(PharmacyColor.textPrimary)
            
            HStack(spacing: 10) {
                Image(systemName: "envelope")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(PharmacyColor.textSecondary)
                
                TextField("pharmacy_team.invite_email_placeholder".localized, text: $email)
                    .font(PharmacyColor.sans(15, .medium))
                    .foregroundStyle(PharmacyColor.textPrimary)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
            .padding(.horizontal, 17)
            .padding(.vertical, 14)
            .background(PharmacyColor.card)
            .clipShape(RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous)
                    .stroke(PharmacyColor.border, lineWidth: 1)
            }
        }
    }
    
    @ViewBuilder
    private var validationBlock: some View {
        if let validationError {
            Text(validationError)
                .font(PharmacyColor.sans(12, .medium))
                .foregroundStyle(PharmacyColor.danger)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 4)
        }
    }
    
    @ViewBuilder
    private var errorBlock: some View {
        if let errorMessage {
            Text(errorMessage)
                .font(PharmacyColor.sans(12, .medium))
                .foregroundStyle(PharmacyColor.danger)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 4)
        }
    }
    
    private var inviteButton: some View {
        Button {
            invite()
        } label: {
            Group {
                if isInviting {
                    ProgressView().tint(.white)
                } else {
                    Text("pharmacy_team.invite_button".localized)
                        .font(PharmacyColor.sans(15, .bold))
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(isInviting ? PharmacyColor.primary.opacity(0.72) : PharmacyColor.primary)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(isInviting)
        .padding(.top, 8)
    }
    
    private func invite() {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard trimmedEmail.contains("@") else {
            validationError = "pharmacy_team.validation_email".localized
            return
        }
        
        guard trimmedEmail.contains(".") else {
            validationError = "pharmacy_team.validation_email".localized
            return
        }
        
        validationError = nil
        
        Task {
            let success = await onInvite(trimmedEmail)
            if success { onCancel() }
        }
    }
}

#Preview {
    InvitePharmacistView(
        pharmacyName: "Test Pharmacy",
        isInviting: false,
        errorMessage: nil,
        onCancel: {},
        onInvite: { _ in true }
    )
}
