//  HomePromoBanner.swift
//  Medsy
//
//  Created by Antoneos Philip on 14/07/2026.
//

import SwiftUI

struct PromoData: Identifiable {
    let id = UUID()
    let titleKey: String
    let discountKey: String
    let targetKey: String
    let buttonKey: String
    let colors: [Color]
    let systemIcon1: String
    let systemIcon2: String
    let systemIcon3: String
    let iconColor1: Color
    let iconColor2: Color
    let iconColor3: Color
}

struct HomePromoBanner: View {
    @State private var currentIndex = 0
    
    private let banners = [
        PromoData(
            titleKey: "home.promoTitle",
            discountKey: "home.promoDiscount",
            targetKey: "home.promoTarget",
            buttonKey: "home.shopNow",
            colors: [Color(hex: "#1A5F35"), Color(hex: "#2A8754"), Color(hex: "#1C6B40")],
            systemIcon1: "bag.fill",
            systemIcon2: "plus.circle.fill",
            systemIcon3: "pills.fill",
            iconColor1: .white,
            iconColor2: Color(hex: "#2A8754"),
            iconColor3: Color(hex: "#F1C40F")
        ),
        PromoData(
            titleKey: "home.promo2.title",
            discountKey: "home.promo2.discount",
            targetKey: "home.promo2.target",
            buttonKey: "home.promo2.button",
            colors: [Color(hex: "#C2410C"), Color(hex: "#EA580C"), Color(hex: "#F97316")],
            systemIcon1: "leaf.fill",
            systemIcon2: "heart.text.square.fill",
            systemIcon3: "capsule.fill",
            iconColor1: .white,
            iconColor2: Color(hex: "#FECACA"),
            iconColor3: Color(hex: "#FDE047")
        ),
        PromoData(
            titleKey: "home.promo3.title",
            discountKey: "home.promo3.discount",
            targetKey: "home.promo3.target",
            buttonKey: "home.promo3.button",
            colors: [Color(hex: "#0369A1"), Color(hex: "#0284C7"), Color(hex: "#38BDF8")],
            systemIcon1: "scooter",
            systemIcon2: "clock.badge.checkmark.fill",
            systemIcon3: "bolt.fill",
            iconColor1: .white,
            iconColor2: Color(hex: "#7DD3FC"),
            iconColor3: Color(hex: "#F59E0B")
        )
    ]
    
    var body: some View {
        VStack(spacing: 12) {
            TabView(selection: $currentIndex) {
                ForEach(0..<banners.count, id: \.self) { index in
                    let promo = banners[index]
                    ZStack {
                        LinearGradient(
                            colors: promo.colors,
                            startPoint: .topTrailing,
                            endPoint: .bottomLeading
                        )
                        .cornerRadius(18)
                        
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(promo.titleKey.localized)
                                    .font(AppColor.sans(20, .bold))
                                    .foregroundStyle(.white)
                                    .multilineTextAlignment(.leading)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(promo.discountKey.localized)
                                        .font(AppColor.sans(14, .bold))
                                        .foregroundStyle(.white.opacity(0.95))
                                        .multilineTextAlignment(.leading)
                                    
                                    Text(promo.targetKey.localized)
                                        .font(AppColor.sans(12))
                                        .foregroundStyle(.white.opacity(0.85))
                                        .multilineTextAlignment(.leading)
                                }
                                
                                Button {
                                } label: {
                                    Text(promo.buttonKey.localized)
                                        .font(AppColor.sans(12, .bold))
                                        .foregroundStyle(promo.colors[1])
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(.white, in: .capsule)
                                }
                                .padding(.top, 4)
                            }
                            .padding(.leading, 20)
                            
                            Spacer()
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.white.opacity(0.15))
                                    .frame(width: 80, height: 95)
                                    .offset(y: 5)
                                
                                VStack(spacing: 4) {
                                    Image(systemName: promo.systemIcon2)
                                        .font(.system(size: 24))
                                        .foregroundStyle(promo.iconColor2)
                                    
                                    Image(systemName: promo.systemIcon1)
                                        .font(.system(size: 32))
                                        .foregroundStyle(promo.iconColor1)
                                }
                                .offset(x: -5, y: -5)
                                
                                Image(systemName: promo.systemIcon3)
                                    .font(.system(size: 28))
                                    .foregroundStyle(promo.iconColor3)
                                    .offset(x: 25, y: 25)
                            }
                            .padding(.trailing, 20)
                        }
                        .padding(.vertical, 16)
                    }
                    .padding(.horizontal)
                    .tag(index)
                }
            }
            .frame(height: 160)
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            HStack(spacing: 6) {
                ForEach(0..<banners.count, id: \.self) { index in
                    Circle()
                        .fill(currentIndex == index ? AppColor.green : AppColor.border)
                        .frame(width: 7, height: 7)
                        .animation(.spring(), value: currentIndex)
                }
            }
        }
    }
}
