import SwiftUI

struct AiChatSuggestionCard: View {
    var iconName: String
    var title: String
    var subtitle: String
    var accentColor: Color = MedsyTheme.default.primary
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                // Icon badge
                Image(systemName: iconName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(accentColor)
                    .frame(width: 34, height: 34)
                    .background(accentColor.opacity(0.12))
                    .clipShape(Circle())

                Spacer(minLength: 0)

                // Title — always 2 lines reserved so height stays equal
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppColor.textPrim)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                // Subtitle — always 1 line reserved
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundColor(AppColor.textSec)
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding(12)
            .background(AppColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: .black.opacity(0.07), radius: 5, y: 2)
            .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}


#Preview {
    AiChatSuggestionCard(
        iconName: "pills.fill",
        title: "Order Medication",
        subtitle: "Refill your prescriptions easily",
        action: {}
    )
    .frame(width: 140, height: 140)
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}
