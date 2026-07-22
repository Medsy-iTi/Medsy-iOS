//  OfferDetailsHeaderView.swift
//  Medsy
//
//  Created by Antoneos Philip on 22/07/2026.

import SwiftUI

struct OfferDetailsHeaderView: View {
    let pharmacyName: String
    let managerName: String
    let onBack: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .trailing, spacing: 4) {
                Text(pharmacyName)
                    .font(AppColor.sans(20, .bold))
                    .foregroundStyle(AppColor.textPrim)
                    .frame(maxWidth: .infinity, alignment: .trailing)

                Text(managerName)
                    .font(AppColor.sans(13))
                    .foregroundStyle(AppColor.textSec)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }

            Button(action: onBack) {
                Image(systemName: "arrow.right")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppColor.textPrim)
                    .frame(width: 36, height: 36)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}
