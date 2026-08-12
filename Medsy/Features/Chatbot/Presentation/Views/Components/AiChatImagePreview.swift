import SwiftUI

struct AiChatImagePreview: View {
    var image: UIImage
    var onDismiss: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.md, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: MedsyRadius.md, style: .continuous)
                        .stroke(AppColor.border, lineWidth: 1)
                )
            
            Button(action: onDismiss) {
                ZStack {
                    Circle()
                        .fill(Color.black.opacity(0.6))
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(width: 20, height: 20)
            }
            .buttonStyle(.plain)
            .offset(x: 8, y: -8)
        }
        .padding([.top, .trailing], 8)
    }
}

#Preview {
    // Providing a placeholder image for preview purposes
    let config = UIImage.SymbolConfiguration(pointSize: 60)
    let image = UIImage(systemName: "photo", withConfiguration: config) ?? UIImage()
    
    return AiChatImagePreview(image: image, onDismiss: {})
        .padding()
}
