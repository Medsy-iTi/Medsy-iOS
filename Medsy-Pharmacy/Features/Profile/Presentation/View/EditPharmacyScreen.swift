//
//  EditPharmacyScreen.swift
//  Medsy-Pharmacy
//

import SwiftUI

struct EditPharmacyScreen: View {

    let pharmacyName: String
    let isSaving: Bool
    let errorMessage: String?
    let onCancel: () -> Void
    let onSave: (String?, String?, String?) async -> Bool

    @State private var draftName: String
    @State private var draftAddress: String
    @State private var draftPhone: String

    init(
        pharmacyName: String,
        pharmacyAddress: String,
        pharmacyPhone: String,
        isSaving: Bool = false,
        errorMessage: String? = nil,
        onCancel: @escaping () -> Void = {},
        onSave: @escaping (String?, String?, String?) async -> Bool = { _, _, _ in true }
    ) {
        self.pharmacyName = pharmacyName
        self.isSaving = isSaving
        self.errorMessage = errorMessage
        self.onCancel = onCancel
        self.onSave = onSave
        _draftName = State(initialValue: pharmacyName)
        _draftAddress = State(initialValue: pharmacyAddress)
        _draftPhone = State(initialValue: pharmacyPhone)
    }

    var body: some View {
        ZStack {
            PharmacyColor.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView(showsIndicators: false) {
                    VStack(spacing: PharmacySpacing.lg) {
                        iconBlock
                        nameField
                        addressField
                        phoneField
                        errorBlock
                        saveButton
                    }
                    .padding(.horizontal, PharmacySpacing.md)
                    .padding(.top, PharmacySpacing.sm)
                    .padding(.bottom, PharmacySpacing.xl)
                }
            }
        }
    }

    // MARK: - Header

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

            Text("pharmacy_edit.title".localized)
                .font(PharmacyColor.sans(17, .bold))
                .foregroundStyle(PharmacyColor.textPrimary)
                .frame(maxWidth: .infinity)

            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.horizontal, PharmacySpacing.md)
        .padding(.vertical, PharmacySpacing.sm)
    }

    // MARK: - Icon Block

    private var iconBlock: some View {
        VStack(spacing: PharmacySpacing.sm) {
            ZStack {
                RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous)
                    .fill(PharmacyColor.primary.opacity(0.12))
                    .frame(width: 72, height: 72)
                Image(systemName: "building.2.fill")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(PharmacyColor.primary)
            }
            Text(pharmacyName)
                .font(PharmacyColor.sans(14, .semibold))
                .foregroundStyle(PharmacyColor.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Fields

    private var nameField: some View {
        editableField(
            titleKey: "pharmacy_edit.name",
            placeholder: "pharmacy_edit.name.placeholder",
            text: $draftName,
            icon: "building.2"
        )
    }

    private var addressField: some View {
        editableField(
            titleKey: "pharmacy_edit.address",
            placeholder: "pharmacy_edit.address.placeholder",
            text: $draftAddress,
            icon: "mappin.and.ellipse",
            axis: .vertical
        )
    }

    private var phoneField: some View {
        editableField(
            titleKey: "pharmacy_edit.phone",
            placeholder: "pharmacy_edit.phone.placeholder",
            text: $draftPhone,
            icon: "phone",
            keyboardType: .phonePad
        )
    }

    private func editableField(
        titleKey: String,
        placeholder: String,
        text: Binding<String>,
        icon: String,
        keyboardType: UIKeyboardType = .default,
        axis: Axis = .horizontal
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(titleKey.localized)
                .font(PharmacyColor.sans(13, .semibold))
                .foregroundStyle(PharmacyColor.textPrimary)

            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(PharmacyColor.textSecondary)

                TextField(placeholder.localized, text: text, axis: axis)
                    .font(PharmacyColor.sans(15, .medium))
                    .foregroundStyle(PharmacyColor.textPrimary)
                    .keyboardType(keyboardType)
					.lineLimit(axis == .vertical ? 3 : 1)
            }
            .padding(.horizontal, 17)
            .padding(.vertical, 14)
            .pharmacyInputSurface()
        }
    }

    // MARK: - Error

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

    // MARK: - Save Button

    private var saveButton: some View {
        Button {
            save()
        } label: {
            Group {
                if isSaving {
                    ProgressView().tint(.white)
                } else {
                    Text("profile.save_changes".localized)
                        .font(PharmacyColor.sans(15, .bold))
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(isSaving ? PharmacyColor.primary.opacity(0.72) : PharmacyColor.primary)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(PharmacyPressableButtonStyle())
        .shadow(color: PharmacyColor.primary.opacity(0.16), radius: 8, y: 4)
        .disabled(isSaving)
        .padding(.top, 8)
    }

    private func save() {
        let name = draftName.trimmingCharacters(in: .whitespacesAndNewlines)
        let address = draftAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        let phone = draftPhone.trimmingCharacters(in: .whitespacesAndNewlines)
        Task {
            let success = await onSave(
                name.isEmpty ? nil : name,
                address.isEmpty ? nil : address,
                phone.isEmpty ? nil : phone
            )
            if success { onCancel() }
        }
    }
}
