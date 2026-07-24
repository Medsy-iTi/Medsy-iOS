//
//  SourceSelection.swift
//  Medsy
//
//  Created by Ehab Salah on 23/07/2026.
//

import SwiftUI


struct SourceSelection: View {
    var viewModel: MedicineAnalyzeViewModelProtocol
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: MedsySpacing.lg) {
                MedicineAnalyzeIntroduction()
                
                MedicineAnalyzeSourceCard(
                    icon: "camera.fill",
                    title: "medicineAnalyze.camera.title".localized,
                    message: "medicineAnalyze.camera.message".localized,
                    tint: AppColor.green,
                    action: viewModel.openCamera
                )
                
                MedicineAnalyzeSourceCard(
                    icon: "photo.on.rectangle.angled",
                    title: "medicineAnalyze.gallery.title".localized,
                    message: "medicineAnalyze.gallery.message".localized,
                    tint: Color(hex: "#2563EB"),
                    action: { viewModel.showsPhotoPicker = true }
                )
                
                MedicineAnalyzeTips()
            }
            .padding(MedsySpacing.md)
        }
    }
}
