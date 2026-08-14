//
//  ProfileSectionContainer.swift
//  Medsy
//
//  Created by Shahudaa on 18/07/2026.
//


import SwiftUI

struct ProfileSectionContainer<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .pharmacyCard(padding: nil, elevation: .subtle)
    }
}

struct ProfileRowDivider: View {
    var body: some View {
        Divider()
            .overlay(PharmacyColor.border)
            .padding(.leading, 56) 
    }
}
