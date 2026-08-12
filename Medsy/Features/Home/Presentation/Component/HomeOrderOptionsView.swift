//  HomeOrderOptionsView.swift
//  Medsy
//
//  Created by Antoneos Philip on 14/07/2026.
//

import SwiftUI

struct HomeOrderOptionsView: View {
    @Environment(LanguageManager.self) private var languageManager
    @ObservedObject private var appSettings = AppSettings.shared
    let onMedicineAnalyze: () -> Void
    let onPrescription: () -> Void

    private let searchBackground = AppColor.blueContainer
    private let searchContent = AppColor.blueContent

    private var prescriptionBackground: Color {
        AppColor.categoryContainer
    }

    private var prescriptionContent: Color {
        AppColor.onCategoryContainer
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("home.weMadeOrderEasy".localized)
                .font(AppColor.sans(16, .bold))
                .foregroundStyle(AppColor.textPrim)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            HStack(spacing: 12) {
                Button {
                    onMedicineAnalyze()
                } label: {
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(searchContent.opacity(0.1))
                                .frame(width: 64, height: 64)
                            
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundStyle(searchContent)
                        }
                        .padding(.top, 16)
                        
                        Text("home.searchForMedicine".localized)
                            .font(AppColor.sans(13, .bold))
                            .foregroundStyle(searchContent)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.8)
                            .lineLimit(1)
                        
                        Text("home.searchForMedicineDesc".localized)
                            .font(AppColor.sans(10))
                            .foregroundStyle(searchContent.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .padding(.horizontal, 8)
                            .padding(.bottom, 16)
                    }
                    .frame(maxWidth: .infinity)
                    .background(searchBackground)
                    .cornerRadius(16)
                    .shadow(color: AppColor.green.opacity(0.18), radius: 12, y: 4)
                }
                
                Button {
                    onPrescription()
                } label: {
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(prescriptionContent.opacity(0.1))
                                .frame(width: 64, height: 64)
                            
                            HStack(spacing: -8) {
                                Image(systemName: "doc.text.fill")
                                    .font(.system(size: 26))
                                    .foregroundStyle(prescriptionContent)
                                
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 18))
                                    .foregroundStyle(prescriptionContent)
                                    .offset(y: 8)
                            }
                        }
                        .padding(.top, 16)
                        
                        Text("home.orderByPrescription".localized)
                            .font(AppColor.sans(13, .bold))
                            .foregroundStyle(prescriptionContent)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.8)
                            .lineLimit(1)
                        
                        Text("home.uploadPrescriptionDesc".localized)
                            .font(AppColor.sans(10))
                            .foregroundStyle(prescriptionContent.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .padding(.horizontal, 8)
                            .padding(.bottom, 16)
                    }
                    .frame(maxWidth: .infinity)
                    .background(prescriptionBackground)
                    .cornerRadius(16)
                    .shadow(color: AppColor.green.opacity(0.18), radius: 12, y: 4)
                }
            }
            .padding(.horizontal)
        }
    }
}
