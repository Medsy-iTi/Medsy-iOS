import SwiftUI

struct CategoryGridCard: View {
    let titleKey: String
    let iconName: String
    let iconColor: Color
    let bgColor: Color
    let itemsCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(bgColor)
                    .frame(width: 50, height: 50)
                
                Image(systemName: iconName)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(titleKey.localized)
                    .font(AppColor.sans(14, .bold))
                    .foregroundStyle(AppColor.textPrim)
                    .lineLimit(1)
                
                Text(String(format: "categories.itemsCount".localized, itemsCount))
                    .font(AppColor.sans(11, .medium))
                    .foregroundStyle(AppColor.textSec)
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
