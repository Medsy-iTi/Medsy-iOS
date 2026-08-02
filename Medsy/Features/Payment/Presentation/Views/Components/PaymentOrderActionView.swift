//
//  PaymentOrderActionView.swift
//  Medsy
//
//  Created by Ahmed Elkady on 02/08/2026.
//

import SwiftUI

struct PaymentOrderActionView: View {
    let action: PaymentOrderActionPresentation
    let onTap: () -> Void

    var body: some View {
        PrimaryButton(
            title: action.title,
            systemImage: action.isLoading ? nil : "creditcard.fill",
            isLoading: action.isLoading,
            isDisabled: action.isLoading,
            action: onTap
        )
    }
}

#Preview {
    VStack {
        PaymentOrderActionView(action: .payNow, onTap: {})
        PaymentOrderActionView(action: .retry, onTap: {})
        PaymentOrderActionView(action: .processing, onTap: {})
    }
    .padding()
}
