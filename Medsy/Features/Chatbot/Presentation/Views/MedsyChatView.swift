
//
//  MedsyChatView.swift
//  Medsy
//


import SwiftUI

// MARK: - Scenario enum (for the interactive demo toggle)

private enum ChatScenario: String, CaseIterable, Identifiable {
    case symptom      = "chatbot.scenario.symptom"
    case prescription = "chatbot.scenario.prescription"
    case pharmacy     = "chatbot.scenario.pharmacy"
    case reorder      = "chatbot.scenario.reorder"

    var id: String { rawValue }

    var localizedTitle: String { rawValue.localized }

    var systemImage: String {
        switch self {
        case .symptom:      return "stethoscope"
        case .prescription: return "doc.text.magnifyingglass"
        case .pharmacy:     return "cross.case.fill"
        case .reorder:      return "arrow.clockwise"
        }
    }
}

// MARK: - MedsyChatView

struct MedsyChatView: View {

    // MARK: Environment
    @Environment(LanguageManager.self) private var lang
    @ObservedObject private var appSettings = AppSettings.shared

    // MARK: Local state
    @State private var draftMessage   = ""
    @State private var scenario       = ChatScenario.symptom
    @State private var reminderOn     = true
    @State private var showScenarioPicker = false

    // MARK: Theme shorthand
    private let theme = MedsyTheme.default

    // MARK: Body
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            scenarioPickerBar
            Divider().background(AppColor.border)

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: MedsySpacing.sm) {
                        content(for: scenario)
                            .padding(.horizontal, MedsySpacing.md)
                            .padding(.top, MedsySpacing.sm)
                            .padding(.bottom, MedsySpacing.lg)
                    }
                    // invisible anchor at bottom
                    Color.clear.frame(height: 1).id("bottom")
                }
                .background(AppColor.bg)
                .onChange(of: scenario) { _, _ in
                    withAnimation { proxy.scrollTo("bottom") }
                }
            }

            inputBar
        }
        .background(AppColor.bg)
        // Propagate RTL / locale so every child respects the selected language
        .localizedEnvironment()
        .environment(lang)
    }

    // MARK: - Navigation bar

    private var navigationBar: some View {
        HStack(spacing: MedsySpacing.xs) {
            // AI avatar
            ZStack {
                RoundedRectangle(cornerRadius: MedsyRadius.sm, style: .continuous)
                    .fill(theme.primary)
                Image(systemName: "plus")
                    .foregroundColor(.white)
                    .font(.system(size: 14, weight: .bold))
            }
            .frame(width: 34, height: 34)

            VStack(alignment: .leading, spacing: 1) {
                Text("chatbot.ai.name".localized)
                    .font(MedsyFont.bodyMedium(15))
                    .foregroundColor(AppColor.textPrim)

                HStack(spacing: 4) {
                    Circle()
                        .fill(AppColor.successGreen)
                        .frame(width: 6, height: 6)
                    Text("chatbot.ai.status.online".localized)
                        .font(MedsyFont.caption(11))
                        .foregroundColor(AppColor.successGreen)
                }
            }

            Spacer()

            // Theme toggle button
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    appSettings.isDarkMode.toggle()
                }
            } label: {
                Image(systemName: appSettings.isDarkMode ? "sun.max.fill" : "moon.fill")
                    .foregroundColor(AppColor.textSec)
                    .frame(width: 36, height: 36)
                    .background(AppColor.surface)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            // Language toggle button
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    lang.toggle()
                }
            } label: {
                Text(lang.isRTL ? "EN" : "ع")
                    .font(MedsyFont.bodyMedium(13))
                    .foregroundColor(AppColor.green)
                    .frame(width: 36, height: 36)
                    .background(AppColor.primaryLight)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, MedsySpacing.md)
        .padding(.vertical, MedsySpacing.sm)
        .background(AppColor.surface)
        // shadow under nav bar
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }

    // MARK: - Scenario picker

    private var scenarioPickerBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: MedsySpacing.xs) {
                ForEach(ChatScenario.allCases) { s in
                    scenarioChip(s)
                }
            }
            .padding(.horizontal, MedsySpacing.md)
            .padding(.vertical, MedsySpacing.xs)
        }
        .background(AppColor.surface)
    }

    private func scenarioChip(_ s: ChatScenario) -> some View {
        let selected = s == scenario
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                scenario = s
            }
        } label: {
            HStack(spacing: 5) {
                Image(systemName: s.systemImage)
                    .font(.system(size: 11, weight: .medium))
                Text(s.localizedTitle)
                    .font(MedsyFont.caption(12))
                    .lineLimit(1)
            }
            .foregroundColor(selected ? .white : AppColor.green)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(
                selected
                ? AppColor.green
                : AppColor.pill
            )
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.75), value: scenario)
    }

    // MARK: - Content router

    @ViewBuilder
    private func content(for s: ChatScenario) -> some View {
        switch s {
        case .symptom:      symptomScenario
        case .prescription: prescriptionScenario
        case .pharmacy:     pharmacyScenario
        case .reorder:      reorderScenario
        }
    }

    // MARK: - Scenario: Symptom / OTC suggestion

    private var symptomScenario: some View {
        VStack(alignment: .leading, spacing: MedsySpacing.sm) {

            disclaimerBanner

            userBubble("chatbot.demo.symptom.q1".localized)
            aiBubble("chatbot.demo.symptom.a1".localized)
            userBubble("chatbot.demo.symptom.q2".localized)

            aiBubbleRich("chatbot.demo.symptom.a2".localized) {
                // Suggested product card
                MedsyProductCard(
                    eyebrow: "chatbot.demo.product.eyebrow.otc".localized,
                    name:    "chatbot.demo.product.panadol.name".localized,
                    subtitle: "chatbot.demo.product.panadol.subtitle".localized,
                    price:   "chatbot.demo.product.panadol.price".localized,
                    primaryButtonTitle: "chatbot.action.add_to_cart".localized,
                    secondaryButtonTitle: "chatbot.action.details".localized,
                    footnote: "chatbot.demo.product.panadol.footnote".localized,
                    accentColor: theme.primary
                )
            }

            // Quick action chips row
            chipRow([
                "chatbot.chip.how_to_take".localized,
                "chatbot.chip.side_effects".localized,
                "chatbot.chip.cheaper".localized
            ])
        }
    }

    // MARK: - Scenario: Prescription reading

    private var prescriptionScenario: some View {
        VStack(alignment: .leading, spacing: MedsySpacing.sm) {

            disclaimerBanner

            userBubble("chatbot.demo.rx.q1".localized)

            aiBubbleRich("chatbot.demo.rx.a1".localized) {
                VStack(spacing: 0) {
                    // Concor row
                    MedsyProductCard(
                        eyebrow: nil,
                        name:    "chatbot.demo.product.concor.name".localized,
                        subtitle: "chatbot.demo.product.concor.subtitle".localized,
                        price:   "chatbot.demo.product.concor.price".localized,
                        badgeText: "chatbot.demo.product.concor.badge".localized,
                        badgeColor: AppColor.successGreen,
                        primaryButtonTitle: "chatbot.action.add_to_cart".localized,
                        accentColor: theme.primary
                    )
                    Divider()
                        .background(AppColor.border)
                        .padding(.horizontal, 16)
                    // Lipitor row
                    MedsyProductCard(
                        eyebrow: nil,
                        name:    "chatbot.demo.product.lipitor.name".localized,
                        subtitle: "chatbot.demo.product.lipitor.subtitle".localized,
                        price:   "chatbot.demo.product.lipitor.price".localized,
                        badgeText: "chatbot.demo.product.lipitor.badge".localized,
                        badgeColor: theme.warning,
                        primaryButtonTitle: "chatbot.action.add_both".localized,
                        secondaryButtonTitle: "chatbot.action.review_each".localized,
                        accentColor: theme.primary
                    )
                }
                .background(AppColor.card)
                .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous))
                .medsyCardShadow()
            }

            // Low-confidence disclaimer
            aiBubble("chatbot.demo.rx.lowconf".localized)

            chipRow([
                "chatbot.chip.side_effects_concor".localized,
                "chatbot.chip.remind_daily".localized
            ])
        }
    }

    // MARK: - Scenario: Pharmacy search & call

    private var pharmacyScenario: some View {
        VStack(alignment: .leading, spacing: MedsySpacing.sm) {

            disclaimerBanner

            userBubble("chatbot.demo.pharmacy.q1".localized)

            aiBubbleRich("chatbot.demo.pharmacy.a1".localized) {
                pharmacyListCard
            }

            aiBubble("chatbot.demo.pharmacy.a2".localized)
            userBubble("chatbot.demo.pharmacy.q2".localized)

            // Call status card
            aiBubbleRich("") {
                MedsyCallStatusCard(
                    title:    "chatbot.demo.call.title".localized,
                    subtitle: "chatbot.demo.call.subtitle".localized,
                    accentColor:    theme.primary,
                    endButtonColor: theme.danger,
                    primaryButtonTitle:   "chatbot.action.end_call".localized,
                    secondaryButtonTitle: "chatbot.action.take_over".localized,
                
                    
                )
            }
        }
    }

    
   
    // MARK: - Scenario: Reorder + reminder + alternative

    private var reorderScenario: some View {
        VStack(alignment: .leading, spacing: MedsySpacing.sm) {

            disclaimerBanner

            // Interaction warning card
            MedsyEmergencyAlertCard(
                iconName: "exclamationmark.triangle.fill",
                title:    "chatbot.demo.interaction.title".localized,
                message:  "chatbot.demo.interaction.message".localized,
                primaryActionTitle:    "chatbot.demo.interaction.action_title".localized,
                primaryActionSubtitle: "chatbot.demo.interaction.action_subtitle".localized,
                secondaryActions: [
                    "chatbot.chip.nearest_hospital".localized,
                    "chatbot.chip.share_location".localized
                ],
                accentColor:     theme.danger,
                backgroundColor: theme.dangerLight
            )

            aiBubble("chatbot.demo.reorder.a1".localized)
            userBubble("chatbot.demo.reorder.q1".localized)

            // Reminder card
            aiBubbleRich("") {
                MedsyReminderCard(
                    title:    "chatbot.demo.reminder.title".localized,
                    subtitle: "chatbot.demo.reminder.subtitle".localized,
                    accentColor: theme.primary,
                    isOn:     $reminderOn
                )
            }
         

            
            aiBubbleRich("") {
                MedsyOrderTrackingCard(
                    label:        "chatbot.demo.order.label".localized,
                    orderId:      "#4218",
                    statusText:   "chatbot.demo.order.status".localized,
                    itemsSummary: "chatbot.demo.order.items".localized,
                    subtotalText: "chatbot.demo.order.subtotal".localized,
                    progress:     0.55,
                    phaseLabel:   "chatbot.demo.order.phase".localized,
                    timeLeft:     "chatbot.demo.order.time_left".localized,
                    accentColor:  theme.primary
                )
            }

            aiBubble("chatbot.demo.alternative.message".localized)

            chipRow([
                "chatbot.chip.switch_to_ator".localized,
                "chatbot.chip.keep_lipitor".localized
            ])
        }
    }

    // MARK: - Sub-views

    private var disclaimerBanner: some View {
        MedsyDisclaimerBanner(
            text: "chatbot.disclaimer".localized,
            backgroundColor: theme.warningLight,
            textColor: theme.warning
        )
    }

    private func userBubble(_ text: String) -> some View {
        MedsyChatBubble(
            text:  text,
            isUser: true,
            userBubbleColor:   theme.primary,
            userTextColor:     .white,
            assistantBubbleColor: AppColor.surface,
            assistantTextColor:   AppColor.textPrim
        )
    }

    private func aiBubble(_ text: String) -> some View {
        HStack(alignment: .top, spacing: MedsySpacing.xs) {
            aiAvatar

            if !text.isEmpty {
                Text(text)
                    .font(MedsyFont.body(15))
                    .foregroundColor(AppColor.textPrim)
                    .padding(.horizontal, MedsySpacing.md)
                    .padding(.vertical, MedsySpacing.sm)
                    .background(AppColor.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .medsyCardShadow()

                Spacer(minLength: 40)
            }
        }
    }

    private func aiBubbleRich<Card: View>(_ text: String, @ViewBuilder card: () -> Card) -> some View {
        HStack(alignment: .top, spacing: MedsySpacing.xs) {
            aiAvatar

            VStack(alignment: .leading, spacing: MedsySpacing.xs) {
                if !text.isEmpty {
                    Text(text)
                        .font(MedsyFont.body(15))
                        .foregroundColor(AppColor.textPrim)
                        .padding(.horizontal, MedsySpacing.md)
                        .padding(.vertical, MedsySpacing.sm)
                        .background(AppColor.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .medsyCardShadow()
                }
                card()
            }

            Spacer(minLength: 16)
        }
    }

    private var aiAvatar: some View {
        ZStack {
            RoundedRectangle(cornerRadius: MedsyRadius.sm, style: .continuous)
                .fill(theme.primary)
            Image(systemName: "plus")
                .foregroundColor(.white)
                .font(.system(size: 11, weight: .bold))
        }
        .frame(width: 28, height: 28)
    }

    /// Horizontal scrolling chip row
    private func chipRow(_ titles: [String]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: MedsySpacing.xs) {
                ForEach(titles, id: \.self) { title in
                    MedsyQuickActionChip(
                        title: title,
                        style: .outline,
                        accentColor: theme.primary,
                        backgroundColor: AppColor.surface
                    )
                }
            }
        }
    }

    /// Pharmacy list wrapped in a card
    private var pharmacyListCard: some View {
        VStack(spacing: 0) {
            MedsyPharmacyRow(
                name:         "chatbot.demo.pharmacy.elezaby.name".localized,
                openStatus:   "chatbot.demo.pharmacy.open24h".localized,
                openStatusColor: AppColor.successGreen,
                distanceInfo: "chatbot.demo.pharmacy.elezaby.distance".localized,
                accentColor:  theme.primary
            )
            Divider().background(AppColor.border).padding(.leading, 52)

            MedsyPharmacyRow(
                name:         "chatbot.demo.pharmacy.misr.name".localized,
                openStatus:   "chatbot.demo.pharmacy.open".localized,
                openStatusColor: AppColor.successGreen,
                distanceInfo: "chatbot.demo.pharmacy.misr.distance".localized,
                accentColor:  theme.primary
            )
            Divider().background(AppColor.border).padding(.leading, 52)

            MedsyPharmacyRow(
                name:         "chatbot.demo.pharmacy.seif.name".localized,
                openStatus:   "chatbot.demo.pharmacy.open".localized,
                openStatusColor: AppColor.successGreen,
                distanceInfo: "chatbot.demo.pharmacy.seif.distance".localized,
                accentColor:  theme.primary
            )
        }
        .padding(.horizontal, MedsySpacing.sm)
        .background(AppColor.card)
        .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous))
        .medsyCardShadow()
    }

    // MARK: - Input bar

    private var inputBar: some View {
        VStack(spacing: 0) {
            Divider().background(AppColor.border)
            MedsyChatInputBar(
                text:        $draftMessage,
                placeholder: "chatbot.input.placeholder".localized,
                accentColor: theme.primary,
                fieldBackground: AppColor.surface
            )
            .padding(.horizontal, MedsySpacing.sm)
            .padding(.vertical, MedsySpacing.sm)
        }
        .background(AppColor.surface)
    }
}

// MARK: - AppColor helpers used above (mapped to MedsyTheme where needed)

private extension AppColor {
    /// Maps to MedsyTheme.default.primaryLight — not in AppColor so we shadow it locally.
    static var primaryLight: Color { Color(hex: "E7F5EE") }
}

// MARK: - Preview

#Preview("Chat – Light / English") {
    let lang = LanguageManager.shared
    return NavigationStack {
        MedsyChatView()
            .environment(lang)
            .localizedEnvironment()
    }
}

#Preview("Chat – Dark / Arabic") {
    let lang = LanguageManager.shared
    AppSettings.shared.isDarkMode = true
    lang.set(.arabic)
    return NavigationStack {
        MedsyChatView()
            .environment(lang)
            .localizedEnvironment()
            .preferredColorScheme(.dark)
    }
}
