import SwiftUI

struct AiChatProductRow: View {
    var product: AIChatProduct
    var onAddToCart: (AIChatProduct) -> Void = { _ in }
    var onDetails: (AIChatProduct) -> Void = { _ in }
    
    var body: some View {
        VStack(alignment: .leading, spacing: MedsySpacing.md) {
            HStack(spacing: MedsySpacing.md) {
                // Product Image
                AsyncImage(url: resolvedImageURL(product.imageURL)) { phase in
                    switch phase {
                    case .empty:
                        ZStack {
                            RoundedRectangle(cornerRadius: MedsyRadius.md)
                                .fill(AppColor.green.opacity(0.08))
                            ProgressView()
                                .scaleEffect(0.7)
                        }
                        .frame(width: 64, height: 64)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 64, height: 64)
                            .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.md))
                    case .failure:
                        ZStack {
                            RoundedRectangle(cornerRadius: MedsyRadius.md)
                                .fill(AppColor.green.opacity(0.12))
                            Image(systemName: "cross.case.fill")
                                .foregroundColor(AppColor.green)
                        }
                        .frame(width: 64, height: 64)
                    @unknown default:
                        Color.clear.frame(width: 64, height: 64)
                    }
                }
                .frame(width: 64, height: 64)                
                // Product Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.productName ?? product.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppColor.textPrim)
                    
                    let details = [product.strength, product.packSize, product.form]
                        .compactMap { $0 }
                        .filter { !$0.isEmpty }
                        .joined(separator: " · ")
                    
                    if !details.isEmpty {
                        Text(details)
                            .font(.system(size: 12))
                            .foregroundColor(AppColor.textSec)
                    }
                    
                    Text(String(format: "EGP %.2f", product.price))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppColor.green)
                }
                
                Spacer()
            }
            
            // Buttons
            HStack(spacing: MedsySpacing.sm) {
                Button(action: { onAddToCart(product) }) {
                    Text("chatbot.product.add_to_cart".localized)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(AppColor.green)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)

                Button(action: { onDetails(product) }) {
                    Text("chatbot.product.details".localized)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColor.green)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .overlay(Capsule().stroke(AppColor.green.opacity(0.4)))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(MedsySpacing.md)
        .padding(.bottom, 12)
        .background(AppColor.card)
        .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous)
                .stroke(AppColor.border.opacity(0.65), lineWidth: 1)
        }
    }
}

// MARK: - URL helpers

private extension AiChatProductRow {
    /// Converts a raw image URL string to a `URL`, percent-encoding any
    /// characters that would cause `URL(string:)` to return nil (spaces, etc.).
    func resolvedImageURL(_ raw: String?) -> URL? {
        guard let raw, !raw.isEmpty else { return nil }
        // Fast path: if the string is already a valid URL, use it directly
        if let url = URL(string: raw) { return url }
        // Slow path: percent-encode characters that the backend may not have escaped
        let encoded = raw.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed
        ) ?? raw
        return URL(string: encoded)
    }
}

#Preview {
    AiChatProductRow(
        product: AIChatProduct(
            id: 1,
            name: "Panadol Extra",
            productName: "Panadol Extra",
            strength: "500 mg",
            packSize: "24 tablets",
            form: "Tablet",
            price: 68.0,
            scientificName: nil,
            scientificCategory: nil,
            categoryID: nil,
            consumerCategory: nil,
            company: nil,
            route: nil,
            description: nil,
            imageURL: nil
        )
    )
    .padding()
}
