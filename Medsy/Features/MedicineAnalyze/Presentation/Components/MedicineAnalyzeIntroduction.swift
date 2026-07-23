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
            Image(systemName: "pills.fill")
                .font(.system(size: 46, weight: .semibold))
                .foregroundStyle(AppColor.green)
                .frame(width: 104, height: 104)
                .background(AppColor.pill, in: Circle())

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
        .padding(.vertical, MedsySpacing.md)
    }
}
