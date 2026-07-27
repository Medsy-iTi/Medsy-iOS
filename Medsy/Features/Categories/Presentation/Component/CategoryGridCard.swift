import SwiftUI

struct CategoryGridCard: View {
    let titleKey: String
    let bgColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(bgColor)
                    .frame(width: 50, height: 50)

                MedsyBrandImageFallback(logoScale: 0.72)
                    .frame(width: 50, height: 50)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(titleKey.localized)
                    .font(AppColor.sans(14, .bold))
                    .foregroundStyle(AppColor.textPrim)
                    .lineLimit(1)
                
              
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(AppColor.card)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 3)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppColor.border, lineWidth: 1)
        )
    }
}
