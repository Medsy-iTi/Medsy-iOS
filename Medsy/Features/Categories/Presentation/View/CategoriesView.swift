import SwiftUI

struct CategoriesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
    private let categories = [
        CategoryItem(
            titleKey: "home.category.medicines",
            iconName: "pills.fill",
            iconColor: Color(hex: "#3B82F6"),
            bgColor: Color(hex: "#EFF6FF")
        ),
        CategoryItem(
            titleKey: "home.category.vitamins",
            iconName: "pills",
            iconColor: Color(hex: "#F97316"),
            bgColor: Color(hex: "#FFF7ED")
        ),
        CategoryItem(
            titleKey: "home.category.personalCare",
            iconName: "sparkles",
            iconColor: Color(hex: "#EC4899"),
            bgColor: Color(hex: "#FDF2F8")
        ),
        CategoryItem(
            titleKey: "home.category.medicalDevices",
            iconName: "waveform.path.ecg",
            iconColor: Color(hex: "#06B6D4"),
            bgColor: Color(hex: "#ECFEFF")
        ),
        CategoryItem(
            titleKey: "home.category.babyCare",
            iconName: "baby.carseat",
            iconColor: Color(hex: "#8B5CF6"),
            bgColor: Color(hex: "#F5F3FF")
        ),
        CategoryItem(
            titleKey: "home.category.skinCare",
            iconName: "face.smiling",
            iconColor: Color(hex: "#10B981"),
            bgColor: Color(hex: "#ECFDF5")
        ),
        CategoryItem(
            titleKey: "home.category.hairCare",
            iconName: "comb.fill",
            iconColor: Color(hex: "#D97706"),
            bgColor: Color(hex: "#FEF3C7")
        ),
        CategoryItem(
            titleKey: "home.category.dailyEssentials",
            iconName: "basket.fill",
            iconColor: Color(hex: "#6B7280"),
            bgColor: Color(hex: "#F3F4F6")
        )
    ]
    
    private let itemsCountMap: [String: Int] = [
        "home.category.medicines": 350,
        "home.category.vitamins": 120,
        "home.category.personalCare": 280,
        "home.category.medicalDevices": 45,
        "home.category.babyCare": 95,
        "home.category.skinCare": 160,
        "home.category.hairCare": 110,
        "home.category.dailyEssentials": 210
    ]
    
    private var filteredCategories: [CategoryItem] {
        if searchText.isEmpty {
            return categories
        } else {
            return categories.filter {
                $0.titleKey.localized.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                TextField("", text: $searchText, prompt:
                    Text("categories.searchPlaceholder".localized)
                        .foregroundStyle(AppColor.textSec)
                )
                .font(AppColor.sans(14))
                .foregroundStyle(AppColor.textPrim)
                .multilineTextAlignment(.leading)
                
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(AppColor.textSec)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppColor.border, lineWidth: 1)
                    .background(AppColor.card.cornerRadius(12))
            )
            .padding()
            
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(filteredCategories) { category in
                        CategoryGridCard(
                            titleKey: category.titleKey,
                            iconName: category.iconName,
                            iconColor: category.iconColor,
                            bgColor: category.bgColor,
                            itemsCount: itemsCountMap[category.titleKey] ?? 0
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .background(AppColor.bg)
        .navigationTitle("categories.title".localized)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(AppColor.textPrim)
                }
            }
        }
    }
}
