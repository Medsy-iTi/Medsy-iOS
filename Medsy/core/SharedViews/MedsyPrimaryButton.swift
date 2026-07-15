//
//  MedsyPrimaryButton.swift
//  Medsy
//
//  Created by Shahudaa on 15/07/2026.
//


import SwiftUI

struct MedsyPrimaryButton: View {
    let title: String
    var isProminent: Bool = true
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(MedsyFont.button())
                .foregroundStyle(isProminent ? AppColor.btnText : AppColor.green)
                .frame(maxWidth: .infinity)
                .padding(.vertical, MedsySpacing.sm + 2)
        }
        .background(
            RoundedRectangle(cornerRadius: MedsyRadius.pill)
                .fill(isProminent ? AppColor.green : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: MedsyRadius.pill)
                        .stroke(isProminent ? .clear : AppColor.green, lineWidth: 1)
                )
        )
        .buttonStyle(.plain)
    }
}
