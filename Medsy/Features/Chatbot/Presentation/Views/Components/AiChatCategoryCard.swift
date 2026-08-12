import SwiftUI

struct AiChatCategoryCard: View {
    var categories: [AIChatCategory]
    var onTap: (AIChatCategory) -> Void = { _ in }

    // MARK: - Artwork mapping (mirrors Category+Presentation.swift by id)
    private func artworkName(for id: Int) -> String? {
        switch id {
        case 1:  return "CategoryMentalHealth"
        case 2:  return "CategoryPainRelief"
        case 3:  return "CategoryColdCough"
        case 4:  return "CategoryBrainNerves"
        case 5:  return "CategorySkinCare"
        case 6:  return "CategoryHeartBloodPressure"
        case 7:  return "CategoryAntivirals"
        case 8:  return "CategoryCancerImmunity"
        case 9:  return "CategoryAllergy"
        case 10: return "CategoryStomachDigestion"
        case 11: return "CategoryAntiparasitics"
        case 12: return "CategoryVitaminsSupplements"
        case 13: return "CategoryAntibiotics"
        case 14: return "CategoryDiabetes"
        case 15: return "CategoryUrinaryKidney"
        case 16: return "CategoryWomensHealth"
        case 17: return "CategoryMensHealth"
        case 18: return "CategoryGout"
        case 19: return "CategoryCholesterol"
        case 20: return "CategoryLiverGallbladder"
        case 21: return "CategoryAntifungals"
        case 22: return "CategoryAsthmaBreathing"
        case 23: return "CategoryHemorrhoidsVeins"
        case 24: return "CategoryEyeCare"
        default: return nil
        }
    }

    private func bgColor(for id: Int) -> Color {
        switch id % 6 {
        case 0:  return Color(hex: "#E8F8F1")
        case 1:  return Color(hex: "#EEF3FF")
        case 2:  return Color(hex: "#FFF2DE")
        case 3:  return Color(hex: "#FCEAF4")
        case 4:  return Color(hex: "#F2EAFE")
        default: return Color(hex: "#EAF8FA")
        }
    }

    static let allCategories: [AIChatCategory] = [
        AIChatCategory(id: 1, name: "home.category.mentalHealth".localized),
        AIChatCategory(id: 2, name: "home.category.painRelief".localized),
        AIChatCategory(id: 3, name: "home.category.coldCough".localized),
        AIChatCategory(id: 4, name: "home.category.brainNerves".localized),
        AIChatCategory(id: 5, name: "home.category.skinCare".localized),
        AIChatCategory(id: 6, name: "home.category.heartBloodPressure".localized),
        AIChatCategory(id: 7, name: "home.category.antivirals".localized),
        AIChatCategory(id: 8, name: "home.category.cancerImmunity".localized),
        AIChatCategory(id: 9, name: "home.category.allergy".localized),
        AIChatCategory(id: 10, name: "home.category.stomachDigestion".localized),
        AIChatCategory(id: 11, name: "home.category.antiparasitics".localized),
        AIChatCategory(id: 12, name: "home.category.vitaminsSupplements".localized),
        AIChatCategory(id: 13, name: "home.category.antibiotics".localized),
        AIChatCategory(id: 14, name: "home.category.diabetes".localized),
        AIChatCategory(id: 15, name: "home.category.urinaryKidney".localized),
        AIChatCategory(id: 16, name: "home.category.womensHealth".localized),
        AIChatCategory(id: 17, name: "home.category.mensHealth".localized),
        AIChatCategory(id: 18, name: "home.category.gout".localized),
        AIChatCategory(id: 19, name: "home.category.cholesterol".localized),
        AIChatCategory(id: 20, name: "home.category.liverGallbladder".localized),
        AIChatCategory(id: 21, name: "home.category.antifungals".localized),
        AIChatCategory(id: 22, name: "home.category.asthmaBreathing".localized),
        AIChatCategory(id: 23, name: "home.category.hemorrhoidsVeins".localized),
        AIChatCategory(id: 24, name: "home.category.eyeCare".localized)
    ]

    var displayCategories: [AIChatCategory] {
        categories.isEmpty ? Self.allCategories : categories
    }

    var body: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 10),
                GridItem(.flexible(), spacing: 10),
                GridItem(.flexible(), spacing: 10),
                GridItem(.flexible(), spacing: 10)
            ],
            spacing: 12
        ) {
            ForEach(displayCategories) { category in
                Button(action: { onTap(category) }) {
                    VStack(spacing: 6) {
                        // Artwork tile
                        Group {
                            if let name = artworkName(for: category.id) {
                                Image(name)
                                    .resizable()
                                    .scaledToFit()
                                    .padding(6)
                            } else {
                                Image(systemName: "pills.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(AppColor.green.opacity(0.7))
                            }
                        }
                        .frame(width: 52, height: 52)
                        .background(bgColor(for: category.id))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(AppColor.border.opacity(0.4), lineWidth: 1)
                        )

                        // Name
                        Text(category.name)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(AppColor.textPrim)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 2)
    }
}

#Preview {
    AiChatCategoryCard(categories: [
        AIChatCategory(id: 2, name: "Pain Relief"),
        AIChatCategory(id: 12, name: "Vitamins"),
        AIChatCategory(id: 3, name: "Cold & Cough"),
        AIChatCategory(id: 9, name: "Allergy"),
        AIChatCategory(id: 13, name: "Antibiotics"),
        AIChatCategory(id: 5, name: "Skin Care"),
        AIChatCategory(id: 14, name: "Diabetes"),
        AIChatCategory(id: 6, name: "Heart & Blood Pressure")
    ])
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}

