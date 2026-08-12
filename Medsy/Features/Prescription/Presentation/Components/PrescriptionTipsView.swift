//
//  PrescriptionTipsView.swift
//  Medsy
//
//  Created by Ehab Salah on 22/07/2026.
//

import SwiftUI

struct PrescriptionTipsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: MedsySpacing.sm) {
            Text("prescription.tips.title".localized)
                .font(.headline)

            Label("prescription.tips.clear".localized, systemImage: "checkmark.circle")
            Label("prescription.tips.shadows".localized, systemImage: "checkmark.circle")
            Label("prescription.tips.full".localized, systemImage: "checkmark.circle")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(AppColor.lightGreen.opacity(0.55), in: RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous))
    }
}
