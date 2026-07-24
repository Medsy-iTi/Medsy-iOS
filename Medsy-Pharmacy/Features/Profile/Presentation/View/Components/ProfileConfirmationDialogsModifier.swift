//
//  ProfileConfirmationDialogsModifier.swift
//  Medsy-Pharmacy
//

import SwiftUI

struct ProfileConfirmationDialogsModifier: ViewModifier {
    @Bindable var viewModel: ProfileViewModel

    func body(content: Content) -> some View {
        content
            .confirmationDialog(
                "pharmacy_card.leave_confirm_title".localized,
                isPresented: $viewModel.showLeavePharmacyConfirmation,
                titleVisibility: .visible
            ) {
                Button("pharmacy_card.leave_confirm_action".localized, role: .destructive) {
                    Task { await viewModel.confirmLeavePharmacy() }
                }
                Button("cancel".localized, role: .cancel) {
                    viewModel.cancelLeavePharmacy()
                }
            } message: {
                Text("pharmacy_card.leave_confirm_message".localized)
            }
            .confirmationDialog(
                "logout_confirmation_title".localized,
                isPresented: $viewModel.showLogoutConfirmation,
                titleVisibility: .visible
            ) {
                Button("logout_confirm_action".localized, role: .destructive) {
                    Task { await viewModel.confirmLogout() }
                }
                Button("cancel".localized, role: .cancel) {
                    viewModel.cancelLogout()
                }
            } message: {
                Text("logout_confirmation_message".localized)
            }
            .confirmationDialog(
                "pharmacy_card.delete_confirm_title".localized,
                isPresented: $viewModel.showDeletePharmacyConfirmation,
                titleVisibility: .visible
            ) {
                Button("pharmacy_card.delete_confirm_action".localized, role: .destructive) {
                    Task { await viewModel.confirmDeletePharmacy() }
                }
                Button("cancel".localized, role: .cancel) {
                    viewModel.cancelDeletePharmacy()
                }
            } message: {
                Text("pharmacy_card.delete_confirm_message".localized)
            }
            .confirmationDialog(
                "pharmacy_team.remove_confirm_title".localized,
                isPresented: $viewModel.showRemovePharmacistConfirmation,
                titleVisibility: .visible
            ) {
                Button("pharmacy_team.remove_confirm_action".localized, role: .destructive) {
                    Task { await viewModel.confirmRemovePharmacist() }
                }
                Button("cancel".localized, role: .cancel) {
                    viewModel.cancelRemovePharmacist()
                }
            } message: {
                if let member = viewModel.selectedPharmacist {
                    Text(
                        String(
                            format: "pharmacy_team.remove_confirm_message".localized,
                            member.fullName
                        )
                    )
                }
            }
    }
}

extension View {
    func profileConfirmationDialogs(viewModel: ProfileViewModel) -> some View {
        modifier(ProfileConfirmationDialogsModifier(viewModel: viewModel))
    }
}
