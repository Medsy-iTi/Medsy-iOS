//
//  MedsyNavBarBackButton.swift
//  Medsy
//
//  Created by Ehab Salah on 23/07/2026.
//

import SwiftUI

struct MedsyNavBarBackButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.backward")
        }
        .accessibilityLabel("accessibility.back".localized)
    }
}
