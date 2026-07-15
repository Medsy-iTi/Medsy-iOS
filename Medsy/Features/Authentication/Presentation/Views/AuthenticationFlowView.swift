//
//  AuthenticationFlowView.swift
//  Medsy
//

import SwiftUI

struct AuthenticationFlowView: View {
    @State private var path: [AuthenticationRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            LoginView {
                path.append(.signup)
            }
            .navigationDestination(for: AuthenticationRoute.self) { route in
                switch route {
                case .login:
                    LoginView {
                        path.append(.signup)
                    }
                case .signup:
                    SignupView {
                        path.removeLast()
                    }
                }
            }
        }
        .tint(AppColor.green)
    }
}

#Preview {
    AuthenticationFlowView()
        .environment(LanguageManager.shared)
}
