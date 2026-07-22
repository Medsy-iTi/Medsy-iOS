//  OffersInfoBannerView.swift
//  Medsy
//
//  Created by Antoneos Philip on 22/07/2026.

import SwiftUI

struct OffersInfoBannerView: View {
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: "info.circle")
                .font(.system(size: 22, weight: .regular))
                .foregroundStyle(AppColor.green)

            VStack(alignment: .trailing, spacing: 4) {
                Text("الأسعار ثابتة من Medsy")
                    .font(AppColor.sans(14, .bold))
                    .foregroundStyle(AppColor.textPrim)
                    .multilineTextAlignment(.trailing)

                Text("الصيدليات يمكنها فقط تطبيق خصم وإضافة رسوم التوصيل")
                    .font(AppColor.sans(12))
                    .foregroundStyle(AppColor.textSec)
                    .multilineTextAlignment(.trailing)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColor.warningBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppColor.warningBorder, lineWidth: 1)
                )
        )
    }
}
