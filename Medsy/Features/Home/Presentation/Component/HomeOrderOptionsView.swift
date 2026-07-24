//  HomeOrderOptionsView.swift
//  Medsy
//
//  Created by Antoneos Philip on 14/07/2026.
//

import SwiftUI

struct HomeOrderOptionsView: View {
    @Environment(LanguageManager.self) private var languageManager
    let onMedicineAnalyze: () -> Void
    let onPrescription: () -> Void
    
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
                                .fill(Color(hex: "#EFF6FF"))
                                .frame(width: 64, height: 64)
                            
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundStyle(Color(hex: "#1E3A8A"))
                        }
                        .padding(.top, 16)
                        
                        Text("home.searchForMedicine".localized)
                            .font(AppColor.sans(13, .bold))
                            .foregroundStyle(AppColor.textPrim)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.8)
                            .lineLimit(1)
                        
                        Text("home.searchForMedicineDesc".localized)
                            .font(AppColor.sans(10))
                            .foregroundStyle(AppColor.textSec)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .padding(.horizontal, 8)
                            .padding(.bottom, 16)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "#F5F7FA"))
                    .cornerRadius(16)
                }
                
                Button {
                    onPrescription()
                } label: {
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "#ECFDF5"))
                                .frame(width: 64, height: 64)
                            
                            HStack(spacing: -8) {
                                Image(systemName: "doc.text.fill")
                                    .font(.system(size: 26))
                                    .foregroundStyle(Color(hex: "#10B981"))
                                
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 18))
                                    .foregroundStyle(Color(hex: "#047857"))
                                    .offset(y: 8)
                            }
                        }
                        .padding(.top, 16)
                        
                        Text("home.orderByPrescription".localized)
                            .font(AppColor.sans(13, .bold))
                            .foregroundStyle(AppColor.textPrim)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.8)
                            .lineLimit(1)
                        
                        Text("home.uploadPrescriptionDesc".localized)
                            .font(AppColor.sans(10))
                            .foregroundStyle(AppColor.textSec)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .padding(.horizontal, 8)
                            .padding(.bottom, 16)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "#F5F7FA"))
                    .cornerRadius(16)
                }
            }
            .padding(.horizontal)
        }
    }
}
