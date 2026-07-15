//  HomeHeaderView.swift
//  Medsy
//
//  Created by Antoneos Philip on 14/07/2026.
//

import SwiftUI

struct HomeHeaderView: View {
    @Environment(LanguageManager.self) private var languageManager
    
    var body: some View {
        HStack {
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    languageManager.toggle()
                }
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell")
                        .font(.title2)
                        .foregroundStyle(AppColor.textPrim)
                    
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                        .offset(x: 2, y: -2)
                }
                .padding(8)
            }
            
            Spacer()
            
            HStack(spacing: 6) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.subheadline)
                    .foregroundStyle(AppColor.textPrim)
                
                Text("home.deliveryTo".localized)
                    .font(AppColor.sans(14, .bold))
                    .foregroundStyle(AppColor.textPrim)
                
                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundStyle(AppColor.textPrim)
            }
            .onTapGesture {
            }
        }
        .environment(\.layoutDirection, .leftToRight)
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}
