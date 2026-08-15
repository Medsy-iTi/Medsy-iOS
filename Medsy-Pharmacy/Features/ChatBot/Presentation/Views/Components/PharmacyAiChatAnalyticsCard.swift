//
//  PharmacyAiChatAnalyticsCard.swift
//  Medsy-Pharmacy
//

import SwiftUI

extension String {
    private var snakeCased: String {
        if self == self.uppercased() {
            return self.lowercased()
        }
        var result = ""
        for (index, char) in self.enumerated() {
            if char.isUppercase && index > 0 {
                result += "_" + char.lowercased()
            } else {
                result += char.lowercased()
            }
        }
        return result
    }

    var localizedPharmacyAnalyticsStatus: String {
        switch self.snakeCased {
        case "completed": return "pharmacy.chatbot.analytics.status.completed".localized
        case "cancelled": return "pharmacy.chatbot.analytics.status.cancelled".localized
        case "rejected":  return "pharmacy.chatbot.analytics.status.rejected".localized
        case "expired":   return "pharmacy.chatbot.analytics.status.expired".localized
        case "pending", "pending_approval": return "pharmacy.orders.status.pending".localized
        case "approved":  return "pharmacy.orders.status.approved".localized
        case "new":       return "pharmacy.orders.filter.new".localized
        default:          return ("pharmacy.chatbot.analytics.status." + self.snakeCased).localized
        }
    }

    var localizedPharmacyAnalyticsMetric: String {
        switch self.snakeCased {
        case "total_revenue": return "pharmacy.chatbot.analytics.metric.total_revenue".localized
        case "completed_orders": return "pharmacy.chatbot.analytics.metric.completed_orders".localized
        case "acceptance_rate": return "pharmacy.chatbot.analytics.metric.acceptance_rate".localized
        case "average_rating": return "pharmacy.chatbot.analytics.metric.average_rating".localized
        case "rejected_orders": return "pharmacy.chatbot.analytics.metric.rejected_orders".localized
        case "average_fulfillment_time": return "pharmacy.chatbot.analytics.metric.average_fulfillment_time".localized
        case "average_order_value": return "pharmacy.chatbot.analytics.metric.average_order_value".localized
        default: return ("pharmacy.chatbot.analytics.metric." + self.snakeCased).localized
        }
    }
}


struct PharmacyAiChatAnalyticsCard: View {
    let analytics: AIChatAnalytics
    var onSelectPharmacist: ((Int) -> Void)? = nil

    private var dateLabel: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        // Use exclusive end date minus 1 second for inclusive display
        let displayEnd = analytics.end?.addingTimeInterval(-1)
        
        let startStr = analytics.start != nil ? formatter.string(from: analytics.start!) : ""
        let endStr = displayEnd != nil ? formatter.string(from: displayEnd!) : ""
        
        if !startStr.isEmpty && !endStr.isEmpty {
            return String(format: "pharmacy.chatbot.analytics.date.range".localized, startStr, endStr)
        } else if !startStr.isEmpty {
            return startStr
        }
        return endStr
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text("pharmacy.chatbot.analytics.title".localized)
                    .font(PharmacyColor.sans(18, .bold))
                    .foregroundColor(PharmacyColor.textPrimary)
                
                if !dateLabel.isEmpty {
                    Text(dateLabel)
                        .font(PharmacyColor.sans(13))
                        .foregroundColor(PharmacyColor.textSecondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            Divider()
            
            if isEmpty {
                emptyState
            } else {
                // Content blocks
                if !analytics.metrics.isEmpty {
                    metricsGrid
                        .padding(.horizontal, 16)
                }
                
                if !analytics.breakdowns.isEmpty {
                    Divider()
                    breakdownsSection
                        .padding(.horizontal, 16)
                }
                
                if !analytics.rankings.isEmpty {
                    Divider()
                    rankingsSection
                }
                
                if !analytics.orderHighlights.isEmpty {
                    Divider()
                    orderHighlightsSection
                }
                
                if !analytics.topProducts.isEmpty {
                    Divider()
                    topProductsSection
                }
            }
        }
        .padding(.bottom, 16)
        .background(PharmacyColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous)
                .stroke(PharmacyColor.border.opacity(0.5), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
    }
    
    private var isEmpty: Bool {
        analytics.metrics.isEmpty &&
        analytics.breakdowns.isEmpty &&
        analytics.rankings.isEmpty &&
        analytics.orderHighlights.isEmpty &&
        analytics.topProducts.isEmpty
    }
    
    private var emptyState: some View {
        Text("pharmacy.chatbot.analytics.empty".localized)
            .font(PharmacyColor.sans(14))
            .foregroundColor(PharmacyColor.textSecondary)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 24)
            .background(PharmacyColor.mutedSurface)
    }
    
    private var metricsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(analytics.metrics, id: \.key) { metric in
                VStack(alignment: .leading, spacing: 8) {
                    Text(metric.key.localizedPharmacyAnalyticsMetric)
                        .font(PharmacyColor.sans(12))
                        .foregroundColor(PharmacyColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text(formatValue(metric.value, unit: metric.unit))
                        .font(PharmacyColor.sans(16, .bold))
                        .foregroundColor(PharmacyColor.primary)
                    
                    if let delta = metric.deltaPercent, delta != 0 {
                        HStack(spacing: 4) {
                            Image(systemName: delta > 0 ? "arrow.up.right" : "arrow.down.right")
                                .font(.system(size: 10, weight: .bold))
                            Text(String(format: "%.1f%%", abs(delta)))
                                .font(PharmacyColor.sans(11, .medium))
                        }
                        .foregroundColor(delta > 0 ? PharmacyColor.success : PharmacyColor.danger)
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(PharmacyColor.mutedSurface)
                .cornerRadius(PharmacyRadius.md)
            }
        }
    }
    
    private var breakdownsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("pharmacy.chatbot.analytics.breakdowns".localized)
                .font(PharmacyColor.sans(14, .bold))
                .foregroundColor(PharmacyColor.textPrimary)
            
            ForEach(analytics.breakdowns, id: \.key) { breakdown in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(breakdown.key.localizedPharmacyAnalyticsStatus)
                            .font(PharmacyColor.sans(13))
                            .foregroundColor(PharmacyColor.textSecondary)
                        Spacer()
                        Text("\(breakdown.count)")
                            .font(PharmacyColor.sans(13, .bold))
                            .foregroundColor(PharmacyColor.textPrimary)
                    }
                    
                    GeometryReader { proxy in
                        let total = Double(analytics.breakdowns.reduce(0) { $0 + $1.count })
                        let fraction = total > 0 ? min(Double(breakdown.count) / total, 1.0) : 0
                        ZStack(alignment: .leading) {
                            Capsule().fill(PharmacyColor.border.opacity(0.3))
                                .frame(height: 6)
                            Capsule().fill(PharmacyColor.primary)
                                .frame(width: proxy.size.width * fraction, height: 6)
                        }
                    }
                    .frame(height: 6)
                }
            }
        }
    }
    
    private var rankingsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("pharmacy.chatbot.analytics.team_ranking".localized)
                .font(PharmacyColor.sans(14, .bold))
                .foregroundColor(PharmacyColor.textPrimary)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            
            ForEach(Array(analytics.rankings.enumerated()), id: \.element.pharmacistID) { idx, entry in
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
                
                if idx < analytics.rankings.count - 1 {
                    Divider()
                }
            }
        }
    }
    
    private var orderHighlightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("pharmacy.chatbot.analytics.orders".localized)
                .font(PharmacyColor.sans(14, .bold))
                .foregroundColor(PharmacyColor.textPrimary)
            
            ForEach(analytics.orderHighlights, id: \.orderId) { highlight in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(String(format: "pharmacy.chatbot.analytics.order_id".localized, highlight.orderId))
                            .font(PharmacyColor.sans(14, .bold))
                            .foregroundColor(PharmacyColor.textPrimary)
                        Text(highlight.status.localizedPharmacyAnalyticsStatus)
                            .font(PharmacyColor.sans(12))
                            .foregroundColor(PharmacyColor.textSecondary)
                    }
                    Spacer()
                    Text(formatValue(highlight.totalPrice, unit: "EGP"))
                        .font(PharmacyColor.sans(14, .bold))
                        .foregroundColor(PharmacyColor.primary)
                }
                .padding(12)
                .background(PharmacyColor.mutedSurface)
                .cornerRadius(PharmacyRadius.md)
            }
        }
        .padding(.horizontal, 16)
    }
    
    private var topProductsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("pharmacy.chatbot.analytics.top_products".localized)
                .font(PharmacyColor.sans(14, .bold))
                .foregroundColor(PharmacyColor.textPrimary)
            
            ForEach(analytics.topProducts, id: \.productId) { product in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(product.productName)
                            .font(PharmacyColor.sans(14, .bold))
                            .foregroundColor(PharmacyColor.textPrimary)
                        Text(String(format: "pharmacy.chatbot.analytics.product_qty".localized, product.quantity))
                            .font(PharmacyColor.sans(12))
                            .foregroundColor(PharmacyColor.textSecondary)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(formatValue(product.revenue, unit: "EGP"))
                            .font(PharmacyColor.sans(14, .bold))
                            .foregroundColor(PharmacyColor.primary)
                        Text(String(format: "pharmacy.chatbot.analytics.product_orders".localized, product.orderCount))
                            .font(PharmacyColor.sans(11))
                            .foregroundColor(PharmacyColor.textSecondary)
                    }
                }
                .padding(12)
                .background(PharmacyColor.mutedSurface)
                .cornerRadius(PharmacyRadius.md)
            }
        }
        .padding(.horizontal, 16)
    }
    
    private func formatValue(_ value: Double, unit: String) -> String {
        switch unit.uppercased() {
        case "EGP":
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = "EGP"
            return formatter.string(from: NSNumber(value: value)) ?? "\(value) EGP"
        case "PERCENT":
            return String(format: "%.1f%%", value)
        case "COUNT":
            return String(format: "%.0f", value)
        default:
            return String(format: "%.1f %@", value, unit)
        }
    }
}
