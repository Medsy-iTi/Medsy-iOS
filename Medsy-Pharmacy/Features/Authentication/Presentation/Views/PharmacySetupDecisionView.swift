import SwiftUI

struct PharmacySetupDecisionView: View {
    let invitationCount: Int
    let onShowInvitations: () -> Void
    let onAddPharmacy: () -> Void
    let onBackToSignIn: () -> Void

    var body: some View {
        GeometryReader { proxy in
            let horizontalPadding = PharmacySpacing.lg
            let contentWidth = min(proxy.size.width, 560) - (horizontalPadding * 2)
            let illustrationHeight = min(
                max(contentWidth * 9 / 16, 150),
                190
            )

            ScrollView {
                VStack(spacing: PharmacySpacing.lg) {
                    illustration(height: illustrationHeight)
                    heading
                    setupOptions

                    Spacer(minLength: PharmacySpacing.lg)

                    VStack(spacing: PharmacySpacing.sm) {
                        PharmacyPrimaryButton(
                            title: "pharmacy.setup.decision.register_action".localized
                        ) {
                            onAddPharmacy()
                        }

                        backToSignInButton
                    }
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, PharmacySpacing.lg)
                .frame(maxWidth: 560)
                .frame(
                    maxWidth: .infinity,
                    minHeight: proxy.size.height,
                    alignment: .top
                )
            }
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)
            .background(PharmacyColor.bg.ignoresSafeArea())
        }
        .navigationBarBackButtonHidden()
    }

    private func illustration(height: CGFloat) -> some View {
        PharmacyLottieView(animationName: "doctors")
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .padding(.horizontal, PharmacySpacing.sm)
            .background(
                PharmacyColor.primarySoft,
                in: RoundedRectangle(
                    cornerRadius: PharmacyRadius.xl,
                    style: .continuous
                )
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: PharmacyRadius.xl,
                    style: .continuous
                )
            )
            .contentShape(
                RoundedRectangle(
                    cornerRadius: PharmacyRadius.xl,
                    style: .continuous
                )
            )
            .accessibilityHidden(true)
    }

    private var heading: some View {
        VStack(spacing: PharmacySpacing.sm) {
            Text("pharmacy.setup.decision.unassigned_title".localized)
                .font(PharmacyColor.sans(25, .bold))
                .foregroundStyle(PharmacyColor.textPrimary)

            Text("pharmacy.setup.decision.unassigned_subtitle".localized)
                .font(PharmacyColor.sans(15))
                .foregroundStyle(PharmacyColor.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, PharmacySpacing.xs)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }

    private var setupOptions: some View {
        VStack(spacing: PharmacySpacing.sm) {
            PharmacySetupDecisionCard(
                title: "pharmacy.setup.decision.register_title".localized,
                subtitle: "pharmacy.setup.decision.register_subtitle".localized,
                systemImage: "building.2.fill"
            )

            if invitationCount > 0 {
                PharmacySetupDecisionCard(
                    title: "pharmacy.setup.decision.invitations_title".localized,
                    subtitle: invitationSubtitle,
                    systemImage: "envelope.badge.fill",
                    showsDisclosure: true,
                    action: onShowInvitations
                )
            } else {
                PharmacySetupDecisionCard(
                    title: "pharmacy.setup.decision.invite_help_title".localized,
                    subtitle: "pharmacy.setup.decision.invite_help_subtitle".localized,
                    systemImage: "envelope.fill"
                )
            }
        }
    }

    private var invitationSubtitle: String {
        if invitationCount == 1 {
            "pharmacy.setup.decision.invitation_count_one".localized
        } else {
            "pharmacy.setup.decision.invitation_count_many".localized(invitationCount)
        }
    }

    private var backToSignInButton: some View {
        Button("pharmacy.setup.decision.back_to_sign_in".localized) {
            onBackToSignIn()
        }
        .font(PharmacyColor.sans(15, .medium))
        .foregroundStyle(PharmacyColor.textSecondary)
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .background(
            PharmacyColor.surface,
            in: RoundedRectangle(
                cornerRadius: PharmacyRadius.md,
                style: .continuous
            )
        )
        .overlay {
            RoundedRectangle(
                cornerRadius: PharmacyRadius.md,
                style: .continuous
            )
            .stroke(PharmacyColor.border, lineWidth: 1)
        }
    }
}

private struct PharmacySetupDecisionCard: View {
    let title: String
    let subtitle: String
    let systemImage: String
    var showsDisclosure = false
    var action: (() -> Void)?

    var body: some View {
        Group {
            if let action {
                Button(action: action) {
                    content
                }
                .buttonStyle(.plain)
            } else {
                content
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(action == nil ? [] : .isButton)
    }

    private var content: some View {
        HStack(spacing: PharmacySpacing.md) {
            Image(systemName: systemImage)
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(PharmacyColor.primary)
                .frame(width: 42, height: 42)
                .background(PharmacyColor.surface.opacity(0.8), in: Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: PharmacySpacing.xs) {
                Text(title)
                    .font(PharmacyColor.sans(14, .bold))
                    .foregroundStyle(PharmacyColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(subtitle)
                    .font(PharmacyColor.sans(13))
                    .foregroundStyle(PharmacyColor.textSecondary)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .layoutPriority(1)

            if showsDisclosure {
                Image(systemName: "chevron.forward")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(PharmacyColor.textPrimary)
                    .accessibilityHidden(true)
            }
        }
        .padding(PharmacySpacing.md)
        .frame(maxWidth: .infinity, minHeight: 96)
        .background(
            PharmacyColor.primarySoft,
            in: RoundedRectangle(
                cornerRadius: PharmacyRadius.lg,
                style: .continuous
            )
        )
        .contentShape(
            RoundedRectangle(
                cornerRadius: PharmacyRadius.lg,
                style: .continuous
            )
        )
    }
}

#Preview("Invitations") {
    NavigationStack {
        PharmacySetupDecisionView(
            invitationCount: 3,
            onShowInvitations: {},
            onAddPharmacy: {},
            onBackToSignIn: {}
        )
    }
    .environment(LanguageManager.shared)
    .pharmacyLocalizedEnvironment()
}

#Preview("No invitations") {
    NavigationStack {
        PharmacySetupDecisionView(
            invitationCount: 0,
            onShowInvitations: {},
            onAddPharmacy: {},
            onBackToSignIn: {}
        )
    }
    .environment(LanguageManager.shared)
    .pharmacyLocalizedEnvironment()
}
