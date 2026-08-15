//
//  MedsyNavBar.swift
//  Medsy
//
//  Created by Shahudaa on 15/07/2026.
//

import SwiftUI

struct MedsyNavBar<Trailing: View>: View {
    @Environment(LanguageManager.self) private var languageManager
    let title: String?
    @ViewBuilder var trailing: () -> Trailing

    init(
        title: String? = nil,
        @ViewBuilder trailing: @escaping () -> Trailing = { EmptyView() }
    ) {
        self.title = title
        self.trailing = trailing
    }

    var body: some View {
        Color.clear
            .frame(height: 0)
            .navigationTitle(title ?? "")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    trailing()
                }
            }
            .toolbarBackground(AppColor.bg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .id(languageManager.currentLanguage)
    }
}
