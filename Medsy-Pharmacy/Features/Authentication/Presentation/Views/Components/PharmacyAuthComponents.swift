//
//  PharmacyAuthComponents.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

import SwiftUI

enum PharmacyAuthFieldKind: Equatable {
    case name
    case phone
    case email
    case address
    case password
    case confirmPassword

    var systemImage: String {
        switch self {
        case .name:
            "person"
        case .phone:
            "phone"
        case .email:
            "envelope"
        case .address:
            "location"
        case .password, .confirmPassword:
            "lock"
        }
    }

    var keyboardType: UIKeyboardType {
        switch self {
        case .phone:
            .phonePad
        case .email:
            .emailAddress
        default:
            .default
        }
    }

    var contentType: UITextContentType? {
        switch self {
        case .name:
            .name
        case .phone:
            .telephoneNumber
        case .email:
            .emailAddress
        case .address:
            .fullStreetAddress
        case .password:
            .newPassword
        case .confirmPassword:
            .newPassword
        }
    }

    var isSecure: Bool {
        self == .password || self == .confirmPassword
    }
}

struct PharmacyAuthScreenContainer<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        ScrollView {
            VStack(spacing: PharmacySpacing.xl) {
                content
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 28)
            .frame(maxWidth: 560)
            .frame(maxWidth: .infinity)
        }
        .scrollDismissesKeyboard(.interactively)
        .scrollIndicators(.hidden)
        .background(PharmacyColor.bg.ignoresSafeArea())
    }
}

struct PharmacyAuthHeader: View {
    let title: String
    let subtitle: String
    var systemImage = "cross.case.fill"
    var showsBrand = false

    var body: some View {
        VStack(spacing: PharmacySpacing.md) {
            if showsBrand {
                PharmacyBrandMark()
            } else {
                Image(systemName: systemImage)
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 64, height: 64)
                    .background(PharmacyColor.primary, in: RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous))
                    .accessibilityHidden(true)

                VStack(spacing: PharmacySpacing.xs) {
                    Text(title)
                        .font(PharmacyColor.sans(24, .bold))
                        .foregroundStyle(PharmacyColor.textPrimary)

                    Text(subtitle)
                        .font(PharmacyColor.sans(14))
                        .foregroundStyle(PharmacyColor.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

private struct PharmacyBrandMark: View {
    var body: some View {
        VStack(spacing: PharmacySpacing.xs) {
            Image("AuthLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 108, height: 108)
                .accessibilityHidden(true)

            Text("pharmacy.auth.brand.name".localized)
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(PharmacyColor.primary)

            Text("pharmacy.auth.brand.tagline".localized)
                .font(PharmacyColor.sans(14, .medium))
                .foregroundStyle(PharmacyColor.textPrimary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\("pharmacy.auth.brand.name".localized), \("pharmacy.auth.brand.tagline".localized)"
        )
    }
}

struct PharmacyAuthTextField: View {
    let title: String
    let kind: PharmacyAuthFieldKind
    @Binding var text: String
    @State private var isPasswordVisible = false
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: PharmacySpacing.sm) {
            Image(systemName: kind.systemImage)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(PharmacyColor.textSecondary)
                .frame(width: 20)

            field

            if kind.isSecure {
                Button {
                    isPasswordVisible.toggle()
                } label: {
                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                        .foregroundStyle(PharmacyColor.textSecondary)
                }
                .accessibilityLabel(
                    isPasswordVisible
                        ? "pharmacy.auth.password.hide".localized
                        : "pharmacy.auth.password.show".localized
                )
            }
        }
        .font(PharmacyColor.sans(15))
        .padding(.horizontal, PharmacySpacing.md)
        .frame(height: 56)
        .pharmacyInputSurface(isFocused: isFocused)
    }

    @ViewBuilder
    private var field: some View {
        if kind.isSecure && !isPasswordVisible {
            SecureField(
                "",
                text: $text,
                prompt: Text(title).foregroundStyle(PharmacyColor.textSecondary)
            )
            .textContentType(kind.contentType)
            .foregroundStyle(PharmacyColor.textPrimary)
            .focused($isFocused)
        } else {
            TextField(
                "",
                text: $text,
                prompt: Text(title).foregroundStyle(PharmacyColor.textSecondary)
            )
            .textContentType(kind.contentType)
            .keyboardType(kind.keyboardType)
            .textInputAutocapitalization(kind == .name ? .words : kind == .address ? .sentences : .never)
            .autocorrectionDisabled(kind == .email)
            .foregroundStyle(PharmacyColor.textPrimary)
            .focused($isFocused)
        }
    }
}

struct PharmacyAuthDatePicker: View {
    @Binding var dateOfBirth: Date

    var body: some View {
        DatePicker(
            "pharmacy.auth.date_of_birth".localized,
            selection: $dateOfBirth,
            in: ...Date(),
            displayedComponents: .date
        )
        .font(PharmacyColor.sans(15))
        .foregroundStyle(PharmacyColor.textPrimary)
        .tint(PharmacyColor.primary)
        .padding(.horizontal, PharmacySpacing.md)
        .frame(height: 56)
        .pharmacyInputSurface()
    }
}



struct PharmacyAuthValidationMessage: View {
    let message: String?

    var body: some View {
        if let message {
            Label(message, systemImage: "exclamationmark.circle.fill")
                .font(PharmacyColor.sans(13, .medium))
                .foregroundStyle(PharmacyColor.danger)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(PharmacySpacing.sm)
                .background(
                    PharmacyColor.danger.opacity(0.08),
                    in: RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous)
                )
        }
    }
}

struct PharmacyAuthPrompt: View {
    let leadingText: String
    let actionTitle: String
    let action: () -> Void

    var body: some View {
        HStack(spacing: PharmacySpacing.xxs) {
            Text(leadingText)
                .foregroundStyle(PharmacyColor.textSecondary)

            Button(actionTitle, action: action)
                .fontWeight(.semibold)
                .foregroundStyle(PharmacyColor.primary)
        }
        .font(PharmacyColor.sans(13))
        .frame(maxWidth: .infinity)
    }
}

struct PharmacyRegistrationProgressView: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        VStack(spacing: PharmacySpacing.xs) {
            HStack {
                Text("pharmacy.auth.registration.progress".localized(currentStep, totalSteps))
                    .font(PharmacyColor.sans(12, .semibold))
                    .foregroundStyle(PharmacyColor.primary)

                Spacer()
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(PharmacyColor.primarySoft)

                    Capsule()
                        .fill(PharmacyColor.primary)
                        .frame(width: proxy.size.width * CGFloat(currentStep) / CGFloat(totalSteps))
                }
            }
            .frame(height: 6)
        }
    }
}

struct PharmacyAuthDivider: View {
    var body: some View {
        HStack(spacing: PharmacySpacing.sm) {
            Rectangle().fill(PharmacyColor.border).frame(height: 1)
            Text("pharmacy.auth.or".localized)
                .font(PharmacyColor.sans(13, .medium))
                .foregroundStyle(PharmacyColor.textSecondary)
            Rectangle().fill(PharmacyColor.border).frame(height: 1)
        }
    }
}

struct PharmacyAuthSecondaryButton: View {
    let title: String
    let imageName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: PharmacySpacing.xs) {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .accessibilityHidden(true)

                Text(title)
                    .font(PharmacyColor.sans(15, .medium))
                    .foregroundStyle(PharmacyColor.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .pharmacyInputSurface()
        }
        .buttonStyle(PharmacyPressableButtonStyle())
        .accessibilityLabel(title)
    }
}
