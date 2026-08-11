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
            systemImage: action.systemImage,
            isLoading: action.isLoading,
            isDisabled: action.isDisabled,
            action: onTap
        )
    }
}

#Preview {
    VStack {
        PaymentOrderActionView(action: .payNow, onTap: {})
        PaymentOrderActionView(action: .retry, onTap: {})
        PaymentOrderActionView(action: .processing, onTap: {})
        PaymentOrderActionView(action: .expired, onTap: {})
    }
    .padding()
}
