//
//  PharmacyAiChatPharmacistRankingCard.swift
//  Medsy-Pharmacy

import SwiftUI

struct PharmacyAiChatPharmacistRankingCard: View {
    var ranking: AIChatPharmacistRanking
    var onSelectPharmacist: ((Int) -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(metricLabel(for: ranking.metric))
                        .font(PharmacyColor.sans(16, .bold))
                        .foregroundColor(PharmacyColor.textPrimary)
                    Text(periodLabel(for: ranking.period))
                        .font(PharmacyColor.sans(12))
                        .foregroundColor(PharmacyColor.textSecondary)
                }
                Spacer()
                directionBadge(for: ranking.direction)
            }
            .padding(16)
            .background(PharmacyColor.surface)

            Divider()

            // List
            if ranking.entries.isEmpty {
                Text("pharmacy.chatbot.ranking.empty".localized)
                    .font(PharmacyColor.sans(14))
                    .foregroundColor(PharmacyColor.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 24)
                    .background(PharmacyColor.mutedSurface)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(ranking.entries.enumerated()), id: \.element.pharmacistID) { idx, entry in
                        Button(action: { onSelectPharmacist?(entry.pharmacistID) }) {
                            HStack(spacing: 12) {
                                Text("\(entry.rank)")
                                    .font(PharmacyColor.sans(14, .bold))
                                    .foregroundColor(PharmacyColor.textSecondary)
                                    .frame(width: 24, alignment: .center)
                                
                                Text("\(entry.firstName) \(entry.lastName)")
                                    .font(PharmacyColor.sans(15, .medium))
                                    .foregroundColor(PharmacyColor.textPrimary)
                                
                                Spacer()
                                
                                Text("\(entry.count)")
                                    .font(PharmacyColor.sans(15, .bold))
                                    .foregroundColor(PharmacyColor.primary)
                                
                                if onSelectPharmacist != nil {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(PharmacyColor.textSecondary.opacity(0.5))
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(idx % 2 == 0 ? PharmacyColor.surface : PharmacyColor.mutedSurface)
                        }
                        .buttonStyle(.plain)
                        .disabled(onSelectPharmacist == nil)
                        
                        if idx < ranking.entries.count - 1 {
                            Divider()
                        }
                    }
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous)
                .stroke(PharmacyColor.border.opacity(0.5), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
    }

    private func metricLabel(for metric: AIChatPerformanceMetric) -> String {
        switch metric {
        case .offersCreated: return "pharmacy.chatbot.ranking.metric.offers".localized
        case .successfulOrders: return "pharmacy.chatbot.ranking.metric.orders".localized
        case .unknown(let s): return s
        }
    }

    private func periodLabel(for period: AIChatPerformancePeriod) -> String {
        switch period {
        case .lastDay: return "pharmacy.chatbot.ranking.period.day".localized
        case .lastWeek: return "pharmacy.chatbot.ranking.period.week".localized
        case .lastMonth: return "pharmacy.chatbot.ranking.period.month".localized
        case .lastYear: return "pharmacy.chatbot.ranking.period.year".localized
        case .unknown(let s): return s
        }
    }

    @ViewBuilder
    private func directionBadge(for direction: AIChatPerformanceDirection) -> some View {
        switch direction {
        case .top:
            Text("pharmacy.chatbot.ranking.direction.top".localized)
                .font(PharmacyColor.sans(11, .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(PharmacyColor.success)
                .clipShape(Capsule())
        case .bottom:
            Text("pharmacy.chatbot.ranking.direction.bottom".localized)
                .font(PharmacyColor.sans(11, .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(PharmacyColor.danger)
                .clipShape(Capsule())
        case .unknown(let s):
            Text(s)
                .font(PharmacyColor.sans(11, .bold))
                .foregroundColor(PharmacyColor.textSecondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(PharmacyColor.border)
                .clipShape(Capsule())
        }
    }
}
