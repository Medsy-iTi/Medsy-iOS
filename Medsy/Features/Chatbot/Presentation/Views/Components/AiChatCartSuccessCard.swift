import SwiftUI

struct AiChatCartSuccessCard: View {
    var quantity: Int
    var cartItemCount: Int
    var onViewCart: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: MedsySpacing.md) {
            HStack(spacing: MedsySpacing.sm) {
                ZStack {
                    Circle()
                        .fill(AppColor.green)
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .bold))
                }
                .frame(width: 28, height: 28)

                Text("chatbot.cart_success.title".localized)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppColor.green)
            }

            Text(String(format: "chatbot.cart_success.subtitle".localized, quantity, cartItemCount))
                .font(.system(size: 14))
                .foregroundColor(AppColor.textSec)

            Button(action: onViewCart) {
                Text("chatbot.cart_success.view_cart".localized)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(AppColor.green)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(MedsySpacing.md)
        .background(AppColor.green.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous)
                .stroke(AppColor.green.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    AiChatCartSuccessCard(quantity: 2, cartItemCount: 5)
        .padding()
}


#Preview {
    AiChatCartSuccessCard(quantity: 2, cartItemCount: 5)
        .padding()
}
