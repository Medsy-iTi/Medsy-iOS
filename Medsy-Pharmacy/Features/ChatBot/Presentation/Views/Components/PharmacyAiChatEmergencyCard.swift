//
//  PharmacyAiChatEmergencyCard.swift
//  Medsy-Pharmacy

import SwiftUI

struct PharmacyAiChatEmergencyCard: View {
    var numbers: [AIChatEmergencyNumber]
    @State private var simulatedCallNumber: String?

    var body: some View {
        VStack(alignment: .leading, spacing: PharmacySpacing.md) {
            HStack(spacing: PharmacySpacing.xs) {
                Image(systemName: "cross.circle.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(PharmacyColor.danger)
                Text("pharmacy.chatbot.emergency.title".localized)
                    .font(PharmacyColor.sans(16, .bold))
                    .foregroundColor(PharmacyColor.textPrimary)
            }

            ForEach(Array(numbers.enumerated()), id: \.element.number) { idx, item in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(serviceName(for: item.service))
                            .font(PharmacyColor.sans(13))
                            .foregroundColor(PharmacyColor.textSecondary)
                        Text(item.number)
                            .font(PharmacyColor.sans(18, .bold))
                            .foregroundColor(PharmacyColor.textPrimary)
                    }
                    Spacer()
                    Button(action: { dialNumber(item.number) }) {
                        HStack(spacing: 4) {
                            Image(systemName: "phone.fill").font(.system(size: 12))
                            Text("pharmacy.chatbot.emergency.call".localized)
                                .font(PharmacyColor.sans(14, .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(PharmacyColor.danger)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
                if idx < numbers.count - 1 { Divider().padding(.vertical, 4) }
            }
        }
        .padding(PharmacySpacing.md)
        .background(PharmacyColor.card)
        .clipShape(RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous))
        .shadow(color: PharmacyColor.danger.opacity(0.08), radius: 6, y: 3)
        .alert("pharmacy.chatbot.emergency.call".localized,
               isPresented: Binding(
                get: { simulatedCallNumber != nil },
                set: { if !$0 { simulatedCallNumber = nil } }
               )) {
            Button("OK", role: .cancel) {}
        } message: {
            if let number = simulatedCallNumber {
                Text("📱 [Simulator] Calling: \(number)")
            }
        }
    }

    private func dialNumber(_ number: String) {
        let cleaned = number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        guard !cleaned.isEmpty else { return }
        #if targetEnvironment(simulator)
        simulatedCallNumber = number
        #else
        if let url = URL(string: "telprompt://\(cleaned)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else if let url = URL(string: "tel://\(cleaned)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
        #endif
    }

    private func serviceName(for service: AIChatEmergencyNumber.Service) -> String {
        switch service {
        case .ambulance: return "pharmacy.chatbot.emergency.ambulance".localized
        case .police:    return "pharmacy.chatbot.emergency.police".localized
        case .fire:      return "pharmacy.chatbot.emergency.fire".localized
        }
    }
}
