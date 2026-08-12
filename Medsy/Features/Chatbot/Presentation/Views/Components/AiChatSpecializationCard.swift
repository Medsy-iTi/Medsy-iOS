import SwiftUI

struct AiChatSpecializationCard: View {
    var specializations: [String]
    var accentColor: Color = MedsyTheme.default.primary

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack(spacing: 6) {
                Image(systemName: "stethoscope")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(accentColor)
                Text("chatbot.specialization.header".localized)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppColor.textSec)
            }

            // Chips — outline style, no filled green
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(specializations, id: \.self) { specialization in
                        Text(specialization)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(accentColor)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(accentColor.opacity(0.08))
                            .overlay(
                                Capsule()
                                    .stroke(accentColor.opacity(0.35), lineWidth: 1)
                            )
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 2) // keeps shadow visible
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }
}

#Preview {
    AiChatSpecializationCard(specializations: ["Cardiology", "Dermatology", "Neurology", "Pediatrics"])
        .padding()
}

