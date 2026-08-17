//
//  HomeQuickDeliveryBanner.swift
//  Medsy
//
//  Created by Antoneos Philip on 25/07/2026.
//

import SwiftUI

struct HomeQuickDeliveryBanner: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("home.fastDelivery".localized)
                    .font(AppColor.sans(14, .bold))
                    .foregroundStyle(AppColor.green)
                
                Text("home.toYourDoorstep".localized)
                    .font(AppColor.sans(12, .medium))
                    .foregroundStyle(AppColor.green.opacity(0.8))
            }
            .padding(.leading, 16)
            
            Spacer()
            
            HStack(spacing: 8) {
                Image(systemName: "box.truck.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(AppColor.green.opacity(0.8))
                
                ZStack {
                    Circle()
                        .fill(AppColor.green.opacity(0.12))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "scooter")
                        .font(.system(size: 22))
                        .foregroundStyle(AppColor.green)
                }
            }
            .padding(.trailing, 16)
        }
        .environment(\.layoutDirection, .leftToRight)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColor.green.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppColor.green.opacity(0.15), lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }
}
