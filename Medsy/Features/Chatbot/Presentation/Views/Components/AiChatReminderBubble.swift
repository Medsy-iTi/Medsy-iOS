import SwiftUI

struct AiChatReminderBubble: View {
    var text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: MedsySpacing.sm) {
            Image(systemName: "bell.fill")
                .foregroundColor(AppColor.warningYellow)
                .font(.system(size: 16))
                .padding(.top, 2)
            
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(AppColor.warningYellow)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(MedsySpacing.md)
        .background(AppColor.warningYellow.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous))
    }
}

#Preview {
    AiChatReminderBubble(text: "Reminder set: Take Panadol Extra at 8:00 AM tomorrow.")
        .padding()
}
