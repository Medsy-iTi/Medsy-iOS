//
//  MedsyNavBar.swift
//  Medsy
//
//  Created by Shahudaa on 15/07/2026.
//

import SwiftUI

struct MedsyNavBar<Trailing: View>: View {
    let title: String?
    let onBack: (() -> Void)?
    @ViewBuilder var trailing: () -> Trailing

    init(
        title: String? = nil,
        onBack: (() -> Void)? = nil,
        @ViewBuilder trailing: @escaping () -> Trailing = { EmptyView() }
    ) {
        self.title = title
        self.onBack = onBack
        self.trailing = trailing
    }

    var body: some View {
        Color.clear
            .frame(height: 0)
            .navigationTitle(title ?? "")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(onBack != nil)
            .toolbar(.visible, for: .navigationBar)
            .toolbar {
                if let onBack {
                    ToolbarItem(placement: .topBarLeading) {
                        MedsyNavBarBackButton(action: onBack)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    trailing()
                }
            }
            .toolbarBackground(AppColor.bg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
    }
}
