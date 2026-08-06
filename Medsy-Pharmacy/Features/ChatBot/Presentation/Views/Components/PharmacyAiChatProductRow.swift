//
//  PharmacyAiChatProductRow.swift
//  Medsy-Pharmacy

import SwiftUI

struct PharmacyAiChatProductRow: View {
    var product: AIChatProduct
    var onDetails: (AIChatProduct) -> Void = { _ in }
    
    var body: some View {
        VStack(alignment: .leading, spacing: PharmacySpacing.md) {
            HStack(spacing: PharmacySpacing.md) {
                AsyncImage(url: product.imageURL.flatMap(URL.init(string:))) { phase in
                    switch phase {
                    case .empty:
                        ProgressView().frame(width: 60, height: 60)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: PharmacyRadius.md))
                    case .failure:
                        ZStack {
                            RoundedRectangle(cornerRadius: PharmacyRadius.md)
                                .fill(PharmacyColor.primary.opacity(0.12))
                            Image(systemName: "cross.case.fill")
                                .foregroundColor(PharmacyColor.primary)
                        }
                        .frame(width: 60, height: 60)
                    @unknown default:
                        EmptyView()
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.productName ?? product.name)
                        .font(PharmacyColor.sans(16, .bold))
                        .foregroundColor(PharmacyColor.textPrimary)
                    
                    let details = [product.strength, product.packSize, product.form]
                        .compactMap { $0 }
                        .filter { !$0.isEmpty }
                        .joined(separator: " · ")
                    
                    if !details.isEmpty {
                        Text(details)
                            .font(PharmacyColor.sans(12))
                            .foregroundColor(PharmacyColor.textSecondary)
                    }
                    
                    Text(String(format: "EGP %.2f", product.price))
                        .font(PharmacyColor.sans(14, .bold))
                        .foregroundColor(PharmacyColor.primary)
                }
                Spacer()
            }
            
            Button(action: { onDetails(product) }) {
                Text("pharmacy.chatbot.product.details".localized)
                    .font(PharmacyColor.sans(14, .semibold))
                    .foregroundColor(PharmacyColor.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .overlay(Capsule().stroke(PharmacyColor.primary.opacity(0.4)))
            }
            .buttonStyle(.plain)
        }
        .padding(PharmacySpacing.md)
        .padding(.bottom, 12)
        .background(PharmacyColor.card)
        .clipShape(RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous))
    }
}
