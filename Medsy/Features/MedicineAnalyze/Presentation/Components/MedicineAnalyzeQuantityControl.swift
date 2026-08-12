//
//  MedicineAnalyzeQuantityControl.swift
//  Medsy
//
//  Created by Ehab Salah on 23/07/2026.
//

import SwiftUI

struct MedicineAnalyzeQuantityControl: View {
    let quantity: Int
    let onAdd: () -> Void
    let onIncrement: () -> Void
    let onDecrement: () -> Void

    var body: some View {
        Group {
            if quantity == 0 {
                Button(action: onAdd) {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(AppColor.green, in: Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("product.add_to_cart".localized)
            } else {
                HStack(spacing: MedsySpacing.xs) {
                    Button(action: onDecrement) {
                        Image(systemName: "minus")
                            .frame(width: 30, height: 30)
                    }

                    Text("\(quantity)")
                        .font(MedsyFont.button(13))
                        .frame(minWidth: 20)

                    Button(action: onIncrement) {
                        Image(systemName: "plus")
                            .foregroundStyle(.white)
                            .frame(width: 30, height: 30)
                            .background(AppColor.green, in: Circle())
                    }
                }
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(AppColor.textPrim)
                .padding(.horizontal, MedsySpacing.xs)
                .background(AppColor.card, in: Capsule())
                .overlay {
                    Capsule().stroke(AppColor.border, lineWidth: 1)
                }
            }
        }
        .buttonStyle(.plain)
    }
}
