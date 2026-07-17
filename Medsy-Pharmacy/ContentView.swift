//
//  ContentView.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 16/07/2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        PharmacyLoginView()
    }
}

#Preview {
    ContentView()
        .environment(LanguageManager.shared)
}
