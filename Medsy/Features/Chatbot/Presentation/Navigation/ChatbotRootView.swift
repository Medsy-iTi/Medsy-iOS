//
//  ChatbotRootView.swift
//  Medsy
//
//  Entry-point view for the Chatbot tab.
//  Wraps MedsyChatView inside a NavigationStack driven by ChatbotCoordinator.
//  The `onTabBarHiddenChange` closure mirrors the convention used by every
//  other coordinator view in MainTabBarView.
//

import SwiftUI

struct ChatbotRootView: View {

    // MARK: - State
    @State private var coordinator = ChatbotCoordinator()

   
    var onTabBarHiddenChange: (Bool) -> Void

   
    init(onTabBarHiddenChange: @escaping (Bool) -> Void) {
        self.onTabBarHiddenChange = onTabBarHiddenChange
    }

    // MARK: - Body
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            MedsyChatView()
                .navigationBarHidden(true)
                .navigationDestination(for: ChatbotRoute.self) { route in
                    destination(for: route)
                }
        }
        .onAppear {
            // Chat view always shows the tab bar on appear
            onTabBarHiddenChange(false)
        }
    }

    // MARK: - Route destinations

    @ViewBuilder
    private func destination(for route: ChatbotRoute) -> some View {
        switch route {
        case .chatDetail:
            MedsyChatView()
                .navigationBarHidden(true)

        case .medicineDetails(let medicineId):
            // Placeholder — wire to ProductDetailView when ready
            VStack {
                Text("Medicine: \(medicineId)")
                    .font(MedsyFont.body())
                    .foregroundColor(AppColor.textPrim)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColor.bg)

        case .pharmacyMap:
            // Placeholder — wire to MapView when ready
            VStack {
                Image(systemName: "map.fill")
                    .font(.system(size: 48))
                    .foregroundColor(AppColor.green)
                Text("Pharmacy Map")
                    .font(MedsyFont.title())
                    .foregroundColor(AppColor.textPrim)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColor.bg)
        }
    }
}

#Preview {
    ChatbotRootView { _ in }
        .environment(LanguageManager.shared)
}
