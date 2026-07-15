//  MainTabBarView.swift
//  Medsy
//
//  Created by Antoneos Philip on 14/07/2026.
//

import SwiftUI

struct MainTabBarView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case 0:
                    VStack {
                        Spacer()
                        Text("Tab \(selectedTab)")
                            .font(AppColor.sans(18, .medium))
                            .foregroundStyle(AppColor.textSec)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(AppColor.bg)
                default:
                    VStack {
                        Spacer()
                        Text("Tab \(selectedTab)")
                            .font(AppColor.sans(18, .medium))
                            .foregroundStyle(AppColor.textSec)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(AppColor.bg)
                }
            }
            .padding(.bottom, 80)
            
            VStack(spacing: 0) {
                Divider()
                    .background(AppColor.border)
                
                HStack(spacing: 0) {
                    tabItem(index: 0, labelKey: "tab.home", activeIcon: "house.fill", inactiveIcon: "house")
                    tabItem(index: 1, labelKey: "tab.favorites", activeIcon: "heart.fill", inactiveIcon: "heart")
                    tabItem(index: 2, labelKey: "tab.offers", activeIcon: "tag.fill", inactiveIcon: "tag")
                    tabItem(index: 3, labelKey: "tab.orders", activeIcon: "doc.text.fill", inactiveIcon: "doc.text")
                    tabItem(index: 4, labelKey: "tab.account", activeIcon: "person.fill", inactiveIcon: "person")
                }
                .padding(.top, 10)
                .padding(.bottom, 24)
                .background(AppColor.card)
            }
            .frame(height: 80)
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    private func tabItem(index: Int, labelKey: String, activeIcon: String, inactiveIcon: String) -> some View {
        let isActive = selectedTab == index
        return Button {
            selectedTab = index
        } label: {
            VStack(spacing: 4) {
                Image(systemName: isActive ? activeIcon : inactiveIcon)
                    .font(.system(size: 20, weight: isActive ? .bold : .regular))
                    .foregroundStyle(isActive ? AppColor.green : AppColor.textSec)
                
                Text(labelKey.localized)
                    .font(AppColor.sans(10, isActive ? .bold : .medium))
                    .foregroundStyle(isActive ? AppColor.green : AppColor.textSec)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
