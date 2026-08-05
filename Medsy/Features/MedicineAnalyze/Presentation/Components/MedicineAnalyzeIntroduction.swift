//
//  MedicineAnalyzeIntroduction.swift
//  Medsy
//
//  Created by Ehab Salah on 23/07/2026.
//

import SwiftUI

struct MedicineAnalyzeIntroduction: View {
    var body: some View {
        VStack(spacing: MedsySpacing.md) {
            ZStack {
                Circle()
                    .fill(AppColor.lightGreen.opacity(0.7))
                    .frame(width: 132, height: 132)

                Image(systemName: "viewfinder")
                    .font(.system(size: 72, weight: .light))
                    .foregroundStyle(AppColor.green.opacity(0.55))

                Image(systemName: "pills.fill")
                    .font(.system(size: 38, weight: .semibold))
                    .foregroundStyle(AppColor.green)
            }

            VStack(spacing: MedsySpacing.xs) {
                Text("medicineAnalyze.heading".localized)
                    .font(MedsyFont.title(22))
                    .foregroundStyle(AppColor.textPrim)

                Text("medicineAnalyze.message".localized)
                    .font(MedsyFont.body(14))
                    .foregroundStyle(AppColor.textSec)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, MedsySpacing.lg)
    }
}
