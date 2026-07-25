//
//  MedicineAnalyzeTipRow.swift
//  Medsy
//
//  Created by Ehab Salah on 23/07/2026.
//

import SwiftUI

struct MedicineAnalyzeTipRow: View {
    let text: String

    var body: some View {
        Label(text, systemImage: "checkmark.circle.fill")
            .font(MedsyFont.caption(13))
            .foregroundStyle(AppColor.textSec)
            .symbolRenderingMode(.hierarchical)
    }
}
