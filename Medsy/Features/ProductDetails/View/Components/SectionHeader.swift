//
//  SectionHeader.swift
//  Medsy
//
//  Created by Shahudaa on 15/07/2026.
//

import SwiftUI

struct SectionHeader: View {
    let title: String

    @Environment(LanguageManager.self) private var languageManager

    var body: some View {
        Text(title)
            .font(MedsyFont.title(17))
            .foregroundStyle(AppColor.textPrim)
            .frame(maxWidth: .infinity, alignment: languageManager.isRTL ? .trailing : .leading)
    }
}

