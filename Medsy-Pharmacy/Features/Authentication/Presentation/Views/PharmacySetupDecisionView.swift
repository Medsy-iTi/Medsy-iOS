import SwiftUI

struct PharmacySetupDecisionView: View {
    let onAddPharmacy: () -> Void
    let onBackToSignIn: () -> Void

    var body: some View {
        PharmacyAuthScreenContainer {
            PharmacyAuthHeader(
                title: "pharmacy.setup.decision.title".localized,
                subtitle: "pharmacy.setup.decision.subtitle".localized,
                systemImage: "cross.case.fill"
            )

            VStack(spacing: PharmacySpacing.md) {
                PharmacyPrimaryButton(
                    title: "pharmacy.setup.decision.add".localized,
                    systemImage: "plus"
                ) {
                    onAddPharmacy()
                }

                Button("pharmacy.setup.decision.back_to_sign_in".localized) {
                    onBackToSignIn()
                }
                .font(PharmacyColor.sans(15, .semibold))
                .foregroundStyle(PharmacyColor.primary)
                .frame(maxWidth: .infinity, minHeight: 48)
            }
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    PharmacySetupDecisionView(onAddPharmacy: {}, onBackToSignIn: {})
        .environment(LanguageManager.shared)
}
