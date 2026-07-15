//  HomeCategoriesView.swift
//  Medsy
//
//  Created by Antoneos Philip on 14/07/2026.
//

import SwiftUI

struct CategoryItem: Identifiable {
    let id = UUID()
    let titleKey: String
    let iconName: String
    let iconColor: Color
    let bgColor: Color
}

struct HomeCategoriesView: View {
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
            titleKey: "home.category.more",
            iconName: "ellipsis",
            iconColor: Color(hex: "#6B7280"),
            bgColor: Color(hex: "#F3F4F6")
        )
    ]
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("home.shopByCategories".localized)
                    .font(AppColor.sans(16, .bold))
                    .foregroundStyle(AppColor.textPrim)
                
                Spacer()
                
//                NavigationLink(destination: CategoriesView()) {
//                    Text("home.viewAll".localized)
//                        .font(AppColor.sans(13, .bold))
//                        .foregroundStyle(AppColor.green)
//                }
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 18) {
                    ForEach(categories) { category in
                        VStack(spacing: 8) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(category.bgColor)
                                    .frame(width: 58, height: 58)
                                
                                Image(systemName: category.iconName)
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundStyle(category.iconColor)
                            }
                            
                            Text(category.titleKey.localized)
                                .font(AppColor.sans(12, .medium))
                                .foregroundStyle(AppColor.textPrim)
                                .lineLimit(1)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
