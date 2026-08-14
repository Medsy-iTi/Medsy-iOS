import SwiftUI

struct AiChatEmergencyCard: View {
    var numbers: [AIChatEmergencyNumber]
    let accentColor = AppColor.errorRed
    @State private var simulatedCallNumber: String?

    var body: some View {
        VStack(alignment: .leading, spacing: MedsySpacing.md) {
            HStack(spacing: 8) {
                Image(systemName: "cross.circle.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(accentColor)
                Text("chatbot.emergency.title".localized)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppColor.textPrim)
            }

            ForEach(Array(numbers.enumerated()), id: \.element.number) { idx, item in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(serviceName(for: item.service))
                            .font(.system(size: 13))
                            .foregroundColor(AppColor.textSec)

                        Text(item.number)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(AppColor.textPrim)
                    }

                    Spacer()

                    Button(action: {
                        let cleaned = item.number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                        guard !cleaned.isEmpty else { return }

                        #if targetEnvironment(simulator)
                        simulatedCallNumber = item.number
                        #else
                        if let url = URL(string: "telprompt://\(cleaned)"), UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url)
                        } else if let url = URL(string: "tel://\(cleaned)"), UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url)
                        }
                        #endif
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "phone.fill")
                                .font(.system(size: 12))
                            Text("chatbot.emergency.call".localized)
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(accentColor)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }

                if idx < numbers.count - 1 {
                    Divider()
                        .padding(.vertical, 4)
                }
            }
        }
        .padding(MedsySpacing.md)
        .background(AppColor.card)
        .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous))
        .shadow(color: accentColor.opacity(0.08), radius: 6, y: 3)
        .alert("pharmacyProfile.call".localized, isPresented: Binding(
            get: { simulatedCallNumber != nil },
            set: { if !$0 { simulatedCallNumber = nil } }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            if let number = simulatedCallNumber {
                Text("📱 [Simulator] Calling: \(number)")
            }
        }
    }

    private func serviceName(for service: AIChatEmergencyNumber.Service) -> String {
        switch service {
        case .ambulance: return "chatbot.emergency.ambulance".localized
        case .police:    return "chatbot.emergency.police".localized
        case .fire:      return "chatbot.emergency.fire".localized
        }
    }
}

#Preview {
    AiChatEmergencyCard(numbers: [
        AIChatEmergencyNumber(service: .ambulance, number: "123"),
        AIChatEmergencyNumber(service: .police, number: "122")
    ])
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}


#Preview {
    AiChatEmergencyCard(numbers: [
        AIChatEmergencyNumber(service: .ambulance, number: "123"),
        AIChatEmergencyNumber(service: .police, number: "122")
    ])
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}
