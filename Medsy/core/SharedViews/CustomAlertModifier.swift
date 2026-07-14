//
//  CustomAlertModifier.swift
//  Medsy
//
//  Created by Ehab Salah on 15/07/2026.
//

import SwiftUI

struct CustomAlertModifier: ViewModifier {
    let title: String
    @Binding var alertMessage: String?
    
    func body(content: Content) -> some View {
        content
            .alert(
                title,
                isPresented: Binding(
                    get: { alertMessage != nil },
                    set: { newValue in if !newValue { alertMessage = nil } }
                )
            ) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage ?? "Unknown Error occurred.")
            }
    }
}


extension View {
    func showCustomAlert(title: String, alertMessage: Binding<String?>) -> some View {
        self.modifier(CustomAlertModifier(title: title, alertMessage: alertMessage))
    }
}
