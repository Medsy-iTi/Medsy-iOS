import SwiftUI

struct PharmacyInvitationBadgeButton: View {
    let count: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: count > 0 ? "bell.fill" : "bell")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(PharmacyColor.primary)
                    .frame(width: 46, height: 46)
                    .background(PharmacyColor.card, in: Circle())
                    .overlay(Circle().stroke(PharmacyColor.border, lineWidth: 1))

                if count > 0 {
                    Text("\(min(count, 99))")
                        .font(PharmacyColor.sans(10, .bold))
                        .foregroundStyle(.white)
                        .frame(minWidth: 20, minHeight: 20)
                        .padding(.horizontal, count > 9 ? 3 : 0)
                        .background(PharmacyColor.danger, in: Capsule())
                        .offset(x: 5, y: -5)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("pharmacy.invitations.notifications".localized)
        .accessibilityValue("pharmacy.invitations.badge_count".localized(count))
    }
}
