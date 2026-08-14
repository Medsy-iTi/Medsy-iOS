//
//  RemovePharmacistView.swift
//  Medsy-Pharmacy
//
//  Remove Pharmacist Confirmation Screen
//

import SwiftUI

struct RemovePharmacistView: View {
    let member: PharmacistMember
    let isRemoving: Bool
    let errorMessage: String?
    let onCancel: () -> Void
    let onRemove: () async -> Bool
    
    var body: some View {
        ZStack {
            PharmacyColor.bg.ignoresSafeArea()
            
            VStack(spacing: 0) {
                header
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: PharmacySpacing.lg) {
                        iconBlock
                        
                        VStack(alignment: .leading, spacing: PharmacySpacing.sm) {
                            Text("pharmacy_team.remove_title".localized)
                                .font(PharmacyColor.sans(16, .bold))
                                .foregroundStyle(PharmacyColor.textPrimary)
                            
                            Text(String(format: "pharmacy_team.remove_message".localized, member.fullName))
                                .font(PharmacyColor.sans(13, .medium))
                                .foregroundStyle(PharmacyColor.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        memberInfoCard
                        warningBlock
                        errorBlock
                        removeButton
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
                    .frame(width: 44, height: 44)
                    .background(PharmacyColor.surface)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(PharmacyColor.border, lineWidth: 1))
            }
            .buttonStyle(PharmacyPressableButtonStyle())
            
            Text("pharmacy_team.remove_header".localized)
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
                    .fill(PharmacyColor.danger.opacity(0.12))
                    .frame(width: 72, height: 72)
                Image(systemName: "person.badge.minus")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(PharmacyColor.danger)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private var memberInfoCard: some View {
        HStack(spacing: PharmacySpacing.sm) {
            ZStack {
                Circle()
                    .fill(PharmacyColor.primary.opacity(0.12))
                    .frame(width: 48, height: 48)
                
                Text(member.fullName.prefix(1).uppercased())
                    .font(PharmacyColor.sans(20, .bold))
                    .foregroundStyle(PharmacyColor.primary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(member.fullName)
                    .font(PharmacyColor.sans(15, .semibold))
                    .foregroundStyle(PharmacyColor.textPrimary)
                
                Text(member.email)
                    .font(PharmacyColor.sans(12, .medium))
                    .foregroundStyle(PharmacyColor.textSecondary)
            }
            
            Spacer()
        }
        .pharmacyCard(cornerRadius: PharmacyRadius.md, elevation: .subtle)
    }
    
    private var warningBlock: some View {
        HStack(spacing: PharmacySpacing.sm) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(PharmacyColor.warning)
            
            Text("pharmacy_team.remove_warning".localized)
                .font(PharmacyColor.sans(12, .medium))
                .foregroundStyle(PharmacyColor.textSecondary)
        }
        .padding(PharmacySpacing.md)
        .background(PharmacyColor.warningSoft)
        .clipShape(RoundedRectangle(cornerRadius: PharmacyRadius.sm, style: .continuous))
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
    
    private var removeButton: some View {
        Button {
            Task {
                let success = await onRemove()
                if success { onCancel() }
            }
        } label: {
            Group {
                if isRemoving {
                    ProgressView().tint(.white)
                } else {
                    Text("pharmacy_team.remove_button".localized)
                        .font(PharmacyColor.sans(15, .bold))
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(isRemoving ? PharmacyColor.danger.opacity(0.72) : PharmacyColor.danger)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(PharmacyPressableButtonStyle())
        .shadow(color: PharmacyColor.danger.opacity(0.16), radius: 8, y: 4)
        .disabled(isRemoving)
        .padding(.top, 8)
    }
}

#Preview {
    RemovePharmacistView(
        member: PharmacistMember(
            id: 1,
            firstName: "John",
            lastName: "Doe",
            email: "john@example.com",
            phoneNumber: "010 1234 5678",
            isAdmin: false
        ),
        isRemoving: false,
        errorMessage: nil,
        onCancel: {},
        onRemove: { true }
    )
}
