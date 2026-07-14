//
//  ContentView.swift
//  Medsy
//
//  Created by Ahmed Elkady on 13/07/2026.
//

import SwiftUI

struct ContentView: View {

    @Environment(LanguageManager.self) private var languageManager

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {

                Text(languageManager.currentLanguage.displayName)
                    .font(.largeTitle.bold())

                Text("common.ok".localized)
                    .foregroundStyle(.secondary)

                Text("common.welcome".localized("Ahmed"))
                    .foregroundStyle(.secondary)

                Divider()

                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        languageManager.toggle()
                    }
                } label: {
                    Label("Switch Language", systemImage: "globe")
                        .padding()
                        .background(.blue, in: .capsule)
                        .foregroundStyle(.white)
                }
            }
            .padding()
            .navigationTitle("common.language".localized)
            .localizedEnvironment()
        }
        .id(languageManager.currentLanguage)
    }
}

#Preview {
    ContentView()
        .environment(LanguageManager.shared)
}
