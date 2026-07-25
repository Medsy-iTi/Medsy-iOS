//
//  PharmacyEditProfileScreen.swift
//  Medsy-Pharmacy
//

import SwiftUI

struct PharmacyEditProfileScreen: View {
	let isSaving: Bool
	let errorMessage: String?
	let onCancel: () -> Void
	let onSave: (String, String, String?, Date?) async -> Bool

	@State private var draftFirstName: String
	@State private var draftLastName: String

	@State private var draftAddress: String
	@State private var includesDateOfBirth: Bool
	@State private var draftDateOfBirth: Date
	@State private var addressError: String?

	init(
		firstName: String,
		lastName: String,
		homeAddress: String,
		dateOfBirth: Date?,
		isSaving: Bool = false,
		errorMessage: String? = nil,
		onCancel: @escaping () -> Void = {},
		onSave: @escaping (String , String ,String?, Date?) async -> Bool = { _, _ ,_, _ in true }
	) {

		self.isSaving = isSaving
		self.errorMessage = errorMessage
		self.onCancel = onCancel
		self.onSave = onSave
		_draftFirstName = State(initialValue: firstName)
		_draftLastName = State(initialValue: lastName)
		_draftAddress = State(initialValue: homeAddress)
		_includesDateOfBirth = State(initialValue: dateOfBirth != nil)
		_draftDateOfBirth = State(
			initialValue: dateOfBirth ?? Self.defaultDateOfBirth
		)
	}

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: PharmacySpacing.lg) {
				Text("profile.personal_information".localized)
					.font(.title3.weight(.bold))
					.foregroundStyle(PharmacyColor.textPrimary)

				editableField(
					title: "profile.first_name".localized,
					text: $draftFirstName,
					icon: "person"
				)

				editableField(
					title: "profile.last_name".localized,
					text: $draftLastName,
					icon: "person"
				)

				addressField
				dateOfBirthField
				errorBlock
			}
			.padding(.horizontal, PharmacySpacing.md)
			.padding(.vertical, PharmacySpacing.lg)
		}
		.background(PharmacyColor.bg.ignoresSafeArea())
		.navigationTitle("profile.edit.title".localized)
		.navigationBarTitleDisplayMode(.inline)
		.interactiveDismissDisabled(isSaving)
		.safeAreaInset(edge: .bottom) {
			saveButton
				.padding(.horizontal, PharmacySpacing.md)
				.padding(.vertical, PharmacySpacing.sm)
				.background(PharmacyColor.bg)
		}
	}

	private func editableField(title: String, text: Binding<String>, icon: String) -> some View {
		VStack(alignment: .leading, spacing: PharmacySpacing.xs) {
			Text(title)
				.font(.caption.weight(.semibold))
				.foregroundStyle(PharmacyColor.textSecondary)

			HStack(spacing: PharmacySpacing.sm) {
				Image(systemName: icon)
					.foregroundStyle(PharmacyColor.textSecondary)
					.frame(width: 24)

				TextField(title, text: text)
					.font(.body)
					.foregroundStyle(PharmacyColor.textPrimary)
					.textInputAutocapitalization(.words)

				Spacer()
			}
			.padding(.horizontal, PharmacySpacing.md)
			.frame(minHeight: 56)
			.background(PharmacyColor.card)
			.clipShape(RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous))
			.overlay {
				RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous)
					.stroke(PharmacyColor.border, lineWidth: 1)
			}
		}
	}

	private var addressField: some View {
		VStack(alignment: .leading, spacing: PharmacySpacing.xs) {
			Text("profile.home_address".localized)
				.font(.caption.weight(.semibold))
				.foregroundStyle(PharmacyColor.textSecondary)

			HStack(alignment: .top, spacing: PharmacySpacing.sm) {
				Image(systemName: "house")
					.foregroundStyle(PharmacyColor.textSecondary)
					.frame(width: 24)
					.padding(.top, 2)

				TextField(
					"profile.home_address.placeholder".localized,
					text: $draftAddress,
					axis: .vertical
				)
				.font(.body)
				.foregroundStyle(PharmacyColor.textPrimary)
				.textInputAutocapitalization(.words)
				.lineLimit(2...4)
				.onChange(of: draftAddress) {
					addressError = nil
				}
			}
			.padding(PharmacySpacing.md)
			.frame(minHeight: 64)
			.background(PharmacyColor.card)
			.clipShape(RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous))
			.overlay {
				RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous)
					.stroke(
						addressError == nil ? PharmacyColor.border : PharmacyColor.danger,
						lineWidth: 1
					)
			}

			if let addressError {
				Text(addressError)
					.font(.caption)
					.foregroundStyle(PharmacyColor.danger)
			}
		}
	}

	private var dateOfBirthField: some View {
		VStack(alignment: .leading, spacing: PharmacySpacing.xs) {
			Text("profile.date_of_birth".localized)
				.font(.caption.weight(.semibold))
				.foregroundStyle(PharmacyColor.textSecondary)

			HStack(spacing: PharmacySpacing.sm) {
				Image(systemName: "calendar")
					.foregroundStyle(PharmacyColor.textSecondary)
					.frame(width: 24)

				if includesDateOfBirth {
					DatePicker(
						"profile.date_of_birth".localized,
						selection: $draftDateOfBirth,
						in: ...Date(),
						displayedComponents: .date
					)
					.labelsHidden()
					.datePickerStyle(.compact)
				} else {
					Button("profile.add_date_of_birth".localized) {
						includesDateOfBirth = true
					}
					.foregroundStyle(PharmacyColor.primary)
				}

				Spacer()

				if includesDateOfBirth {
					Button {
						includesDateOfBirth = false
					} label: {
						Image(systemName: "xmark.circle.fill")
							.foregroundStyle(PharmacyColor.textSecondary)
					}
					.buttonStyle(.plain)
					.accessibilityLabel("profile.remove_date_of_birth".localized)
				}
			}
			.padding(.horizontal, PharmacySpacing.md)
			.frame(minHeight: 56)
			.background(PharmacyColor.card)
			.clipShape(RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous))
			.overlay {
				RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous)
					.stroke(PharmacyColor.border, lineWidth: 1)
			}
		}
	}

	@ViewBuilder
	private var errorBlock: some View {
		if let errorMessage {
			Text(errorMessage)
				.font(.caption)
				.foregroundStyle(PharmacyColor.danger)
				.frame(maxWidth: .infinity, alignment: .leading)
		}
	}

	private var saveButton: some View {
		Button(action: save) {
			Group {
				if isSaving {
					ProgressView().tint(.white)
				} else {
					Text("profile.save_changes".localized)
						.font(.headline)
				}
			}
			.foregroundStyle(.white)
			.frame(maxWidth: .infinity, minHeight: 52)
		}
		.buttonStyle(.plain)
		.background(
			isSaving ? PharmacyColor.primary.opacity(0.72) : PharmacyColor.primary,
			in: RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous)
		)
		.disabled(isSaving)
	}

	private func save() {
		let trimmedFirstName = draftFirstName.trimmingCharacters(in: .whitespacesAndNewlines)
		let trimmedLastName = draftLastName.trimmingCharacters(in: .whitespacesAndNewlines)
		let trimmedAddress = draftAddress.trimmingCharacters(in: .whitespacesAndNewlines)

		guard !trimmedFirstName.isEmpty, !trimmedLastName.isEmpty else {
			addressError = "pharmacy_team.validation_name".localized // reusing error state for simplicity or you can add a separate error state
			return
		}

		guard trimmedAddress.isEmpty || trimmedAddress.count >= 4 else {
			addressError = "profile.address_error".localized
			return
		}

		Task {
			let success = await onSave(
				trimmedFirstName,
				trimmedLastName,
				trimmedAddress.isEmpty ? nil : trimmedAddress,
				includesDateOfBirth ? draftDateOfBirth : nil
			)
			if success {
				onCancel()
			}
		}
	}

	private static var defaultDateOfBirth: Date {
		Calendar.current.date(
			from: DateComponents(year: 1995, month: 1, day: 1)
		) ?? Date()
	}
}
