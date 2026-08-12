import SwiftUI

struct AiChatConfirmRequestCard: View {
    var onConfirm: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: MedsySpacing.md) {
            HStack(spacing: MedsySpacing.sm) {
                ZStack {
                    Circle()
                        .fill(AppColor.green.opacity(0.15))
                    Image(systemName: "doc.badge.plus")
                        .foregroundColor(AppColor.green)
                        .font(.system(size: 16))
                }
                .frame(width: 32, height: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text("chatbot.confirm_request.title".localized)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppColor.textPrim)

                    Text("chatbot.confirm_request.subtitle".localized)
                        .font(.system(size: 13))
                        .foregroundColor(AppColor.textSec)
                }

                Spacer()
            }

            Button(action: onConfirm) {
                Text("chatbot.confirm_request.action".localized)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(AppColor.green)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(MedsySpacing.md)
        .background(AppColor.card)
        .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    AiChatConfirmRequestCard()
        .padding()
        .background(Color(UIColor.systemGroupedBackground))
}


#Preview {
    AiChatConfirmRequestCard()
        .padding()
        .background(Color(UIColor.systemGroupedBackground))
}
