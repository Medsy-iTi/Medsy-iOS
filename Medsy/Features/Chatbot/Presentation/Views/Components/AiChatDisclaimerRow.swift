import SwiftUI

struct AiChatDisclaimerRow: View {
    var text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            Image(systemName: "info.circle")
                .foregroundColor(AppColor.textSec)
                .font(.system(size: 12))
                .padding(.top, 1)
            
            Text(text)
                .font(.system(size: 11, weight: .regular, design: .default).italic())
                .foregroundColor(AppColor.textSec)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, MedsySpacing.sm)
        .padding(.vertical, MedsySpacing.xs)
    }
}

#Preview {
    AiChatDisclaimerRow(text: "This is AI-generated advice and does not replace professional medical consultation.")
        .padding()
}
