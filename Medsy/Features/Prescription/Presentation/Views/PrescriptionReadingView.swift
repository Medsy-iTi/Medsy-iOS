//
//  PrescriptionReadingView.swift
//  Medsy
//
//  Created by Ehab Salah on 22/07/2026.
//

import SwiftUI

// MARK: - View

struct PrescriptionReadingView: View {
    let onCancel: () -> Void

    var body: some View {
        PrescriptionPage(title: "prescription.reading.title".localized, onBack: onCancel) {
            VStack(spacing: MedsySpacing.xl) {
                ProgressView()
                    .controlSize(.large)
                    .tint(AppColor.green)

                VStack(spacing: MedsySpacing.xs) {
                    Text("prescription.reading.heading".localized)
                        .font(.title3.weight(.bold))

                    Text("prescription.reading.message".localized)
                        .font(.body)
                        .foregroundStyle(AppColor.textSec)
                        .multilineTextAlignment(.center)
                }

                Button("common.cancel".localized, action: onCancel)
                    .foregroundStyle(AppColor.green)
            }
            .padding(.horizontal, MedsySpacing.xl)
            .padding(.top, 72)
        }
    }
}
