//
//  PharmacyCompletedOrderDetailLoadingSkeleton.swift
//  Medsy
//
//  Created by Shahudaa on 26/07/2026.
//


import SwiftUI

struct PharmacyCompletedOrderDetailLoadingSkeleton: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: PharmacySpacing.md) {

                VStack(alignment: .leading, spacing: PharmacySpacing.xs) {
                    HStack {
                        VStack(alignment: .leading, spacing: PharmacySpacing.xs) {
                            PharmacySkeletonBlock(width: 140, height: 20)
                            PharmacySkeletonBlock(width: 110, height: 13)
                        }
                        Spacer(minLength: 0)
                        PharmacySkeletonBlock(width: 88, height: 28, cornerRadius: 14)
                    }
                    PharmacySkeletonBlock(width: 160, height: 13)
                }
                .pharmacyCard()


                VStack(alignment: .leading, spacing: PharmacySpacing.sm) {
                    HStack(spacing: PharmacySpacing.sm) {
                        PharmacySkeletonBlock(width: 44, height: 44, cornerRadius: 22)
                        VStack(alignment: .leading, spacing: 6) {
                            PharmacySkeletonBlock(width: 72, height: 12)
                            PharmacySkeletonBlock(width: 156, height: 16)
                        }
                        Spacer(minLength: 0)
                    }
                    PharmacyDivider()
                    HStack(spacing: PharmacySpacing.sm) {
                        PharmacySkeletonBlock(width: 24, height: 14)
                        PharmacySkeletonBlock(width: 180, height: 14)
                    }
                    HStack(spacing: PharmacySpacing.sm) {
                        PharmacySkeletonBlock(width: 24, height: 14)
                        PharmacySkeletonBlock(width: 130, height: 14)
                    }
                }
                .pharmacyCard()


                VStack(alignment: .leading, spacing: PharmacySpacing.xs) {
                    PharmacySkeletonBlock(width: 104, height: 16)
                    VStack(spacing: 0) {
                        ForEach(0..<2, id: \.self) { index in
                            HStack(spacing: PharmacySpacing.sm) {
                                PharmacySkeletonBlock(width: 56, height: 56, cornerRadius: PharmacyRadius.sm)
                                VStack(alignment: .leading, spacing: 6) {
                                    PharmacySkeletonBlock(width: 150, height: 14)
                                    PharmacySkeletonBlock(width: 100, height: 12)
                                }
                                Spacer(minLength: 0)
                                PharmacySkeletonBlock(width: 60, height: 14)
                            }
                            .padding(.horizontal, PharmacySpacing.md)
                            .padding(.vertical, PharmacySpacing.sm)
                            if index < 1 {
                                PharmacyDivider()
                                    .padding(.leading, 56 + PharmacySpacing.md)
                            }
                        }
                    }
                    .pharmacyCard(padding: nil)
                }

             
                VStack(alignment: .leading, spacing: PharmacySpacing.sm) {
                    PharmacySkeletonBlock(width: 126, height: 16)
                    ForEach(0..<3, id: \.self) { _ in
                        HStack {
                            PharmacySkeletonBlock(width: 112, height: 14)
                            Spacer(minLength: 0)
                            PharmacySkeletonBlock(width: 76, height: 14)
                        }
                    }
                }
                .pharmacyCard()
            }
            .padding(PharmacySpacing.md)
        }
        .background(PharmacyColor.bg)
        .accessibilityLabel("common.loading".localized)
    }
}

#Preview {
    PharmacyCompletedOrderDetailLoadingSkeleton()
        .background(PharmacyColor.bg)
}
