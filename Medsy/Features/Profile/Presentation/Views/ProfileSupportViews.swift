//
//  ProfileSupportViews.swift
//  Medsy
//
//  Created by Ahmed Elkady on 13/08/2026.
//

import SwiftUI

struct HowMedsyWorksView: View {
    let onBack: () -> Void

    private let steps = [
        ProfileGuideStep(icon: "magnifyingglass", color: Color(hex: "#3B82F6"), titleKey: "profile.guide.search.title", bodyKey: "profile.guide.search.body"),
        ProfileGuideStep(icon: "doc.text.viewfinder", color: AppColor.green, titleKey: "profile.guide.request.title", bodyKey: "profile.guide.request.body"),
        ProfileGuideStep(icon: "building.2", color: Color(hex: "#A855F7"), titleKey: "profile.guide.offer.title", bodyKey: "profile.guide.offer.body"),
        ProfileGuideStep(icon: "creditcard", color: Color(hex: "#F59E0B"), titleKey: "profile.guide.payment.title", bodyKey: "profile.guide.payment.body"),
        ProfileGuideStep(icon: "shippingbox", color: Color(hex: "#38BDF8"), titleKey: "profile.guide.track.title", bodyKey: "profile.guide.track.body")
    ]

    var body: some View {
        VStack(spacing: 0) {
            MedsyNavBar(title: "profile.how_it_works".localized, onBack: onBack)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    supportHero(
                        icon: "sparkles",
                        titleKey: "profile.guide.title",
                        bodyKey: "profile.guide.subtitle"
                    )

                    VStack(spacing: 12) {
                        ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                            guideStepCard(number: index + 1, step: step)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
        }
        .background(ProfileStyle.background.ignoresSafeArea())
        .localizedEnvironment()
    }

    private func guideStepCard(number: Int, step: ProfileGuideStep) -> some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(step.color.opacity(0.16))
                    .frame(width: 48, height: 48)

                Image(systemName: step.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(step.color)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("profile.guide.step".localized(number))
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(step.color)

                Text(step.titleKey.localized)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(ProfileStyle.primaryText)

                Text(step.bodyKey.localized)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(ProfileStyle.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(ProfileStyle.card)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(ProfileStyle.border, lineWidth: 1)
        }
    }
}

struct ProfileHelpCenterView: View {
    let onBack: () -> Void

    @State private var searchText = ""
    @State private var expandedQuestionID: String?

    private let questions = [
        ProfileFAQ(id: "request", questionKey: "profile.faq.request.question", answerKey: "profile.faq.request.answer"),
        ProfileFAQ(id: "offer", questionKey: "profile.faq.offer.question", answerKey: "profile.faq.offer.answer"),
        ProfileFAQ(id: "payment", questionKey: "profile.faq.payment.question", answerKey: "profile.faq.payment.answer"),
        ProfileFAQ(id: "prescription", questionKey: "profile.faq.prescription.question", answerKey: "profile.faq.prescription.answer"),
        ProfileFAQ(id: "delivery", questionKey: "profile.faq.delivery.question", answerKey: "profile.faq.delivery.answer"),
        ProfileFAQ(id: "cancel", questionKey: "profile.faq.cancel.question", answerKey: "profile.faq.cancel.answer")
    ]

    private var filteredQuestions: [ProfileFAQ] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return questions }
        return questions.filter {
            $0.questionKey.localized.localizedCaseInsensitiveContains(query) ||
            $0.answerKey.localized.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            MedsyNavBar(title: "profile.help_center".localized, onBack: onBack)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    supportHero(
                        icon: "lifepreserver.fill",
                        titleKey: "profile.help.title",
                        bodyKey: "profile.help.subtitle"
                    )

                    searchField

                    if filteredQuestions.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "questionmark.folder")
                                .font(.system(size: 34, weight: .medium))
                                .foregroundStyle(ProfileStyle.secondaryText)
                            Text("profile.help.no_results".localized)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(ProfileStyle.secondaryText)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 44)
                    } else {
                        VStack(spacing: 10) {
                            ForEach(filteredQuestions) { question in
                                faqCard(question)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
        }
        .background(ProfileStyle.background.ignoresSafeArea())
        .localizedEnvironment()
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(ProfileStyle.secondaryText)

            TextField("profile.help.search".localized, text: $searchText)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(ProfileStyle.primaryText)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(ProfileStyle.secondaryText)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("common.clear".localized)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
        .background(ProfileStyle.card)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(ProfileStyle.border, lineWidth: 1)
        }
    }

    private func faqCard(_ question: ProfileFAQ) -> some View {
        let isExpanded = expandedQuestionID == question.id

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                expandedQuestionID = isExpanded ? nil : question.id
            }
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 12) {
                    Text(question.questionKey.localized)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(ProfileStyle.primaryText)
                        .multilineTextAlignment(.leading)

                    Spacer(minLength: 8)

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(AppColor.green)
                }

                if isExpanded {
                    Divider()
                        .background(ProfileStyle.border)
                        .padding(.vertical, 12)

                    Text(question.answerKey.localized)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(ProfileStyle.secondaryText)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(ProfileStyle.card)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isExpanded ? AppColor.green : ProfileStyle.border, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}

struct ReportProblemView: View {
    let onBack: () -> Void

    @State private var selectedCategory: ProfileIssueCategory = .technical
    @State private var details = ""
    @State private var isSubmitting = false
    @State private var submittedReference: String?

    private let submissionService: any ProfileSupportSubmissionService = MockProfileSupportSubmissionService()

    private var canSubmit: Bool {
        !details.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSubmitting
    }

    var body: some View {
        VStack(spacing: 0) {
            MedsyNavBar(title: "profile.report_issue".localized, onBack: onBack)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    supportHero(
                        icon: "exclamationmark.bubble.fill",
                        titleKey: "profile.report.title",
                        bodyKey: "profile.report.subtitle"
                    )

                    fieldTitle("profile.report.category")
                    categoryPicker

                    fieldTitle("profile.report.details")
                    detailsEditor

                    mockNotice
                    submitButton
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
        }
        .background(ProfileStyle.background.ignoresSafeArea())
        .localizedEnvironment()
        .alert("profile.report.success.title".localized, isPresented: successAlertBinding) {
            Button("common.done".localized) { onBack() }
        } message: {
            if let submittedReference {
                Text("profile.report.success.message".localized(submittedReference))
            }
        }
    }

    private func fieldTitle(_ key: String) -> some View {
        Text(key.localized)
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(ProfileStyle.primaryText)
    }

    private var categoryPicker: some View {
        Menu {
            ForEach(ProfileIssueCategory.allCases) { category in
                Button {
                    selectedCategory = category
                } label: {
                    Label(category.titleKey.localized, systemImage: category.icon)
                }
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: selectedCategory.icon)
                    .foregroundStyle(AppColor.green)
                    .frame(width: 24)

                Text(selectedCategory.titleKey.localized)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(ProfileStyle.primaryText)

                Spacer()

                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(ProfileStyle.secondaryText)
            }
            .padding(.horizontal, 16)
            .frame(height: 54)
            .background(ProfileStyle.card)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(ProfileStyle.border, lineWidth: 1)
            }
        }
    }

    private var detailsEditor: some View {
        ZStack(alignment: .topLeading) {
            if details.isEmpty {
                Text("profile.report.details.placeholder".localized)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(ProfileStyle.secondaryText.opacity(0.72))
                    .padding(.horizontal, 17)
                    .padding(.vertical, 17)
                    .allowsHitTesting(false)
            }

            TextEditor(text: $details)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(ProfileStyle.primaryText)
                .scrollContentBackground(.hidden)
                .padding(10)
                .frame(minHeight: 150)
        }
        .background(ProfileStyle.card)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(ProfileStyle.border, lineWidth: 1)
        }
    }

    private var mockNotice: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(AppColor.green)

            Text("profile.report.mock_notice".localized)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(ProfileStyle.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(AppColor.green.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var submitButton: some View {
        Button {
            submit()
        } label: {
            HStack(spacing: 10) {
                if isSubmitting {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "paperplane.fill")
                }

                Text(isSubmitting ? "profile.report.submitting".localized : "profile.report.submit".localized)
            }
            .font(.system(size: 15, weight: .bold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(canSubmit ? AppColor.green : AppColor.green.opacity(0.45))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(!canSubmit)
    }

    private var successAlertBinding: Binding<Bool> {
        Binding(
            get: { submittedReference != nil },
            set: { if !$0 { submittedReference = nil } }
        )
    }

    private func submit() {
        guard canSubmit else { return }
        isSubmitting = true
        let category = selectedCategory
        let message = details.trimmingCharacters(in: .whitespacesAndNewlines)

        Task {
            let reference = await submissionService.submit(category: category, details: message)
            await MainActor.run {
                isSubmitting = false
                submittedReference = reference
            }
        }
    }
}

private struct ProfileGuideStep {
    let icon: String
    let color: Color
    let titleKey: String
    let bodyKey: String
}

private struct ProfileFAQ: Identifiable {
    let id: String
    let questionKey: String
    let answerKey: String
}

private enum ProfileIssueCategory: String, CaseIterable, Identifiable, Sendable {
    case order
    case payment
    case account
    case technical
    case other

    var id: String { rawValue }
    var titleKey: String { "profile.report.category.\(rawValue)" }

    var icon: String {
        switch self {
        case .order: "shippingbox"
        case .payment: "creditcard"
        case .account: "person.crop.circle"
        case .technical: "wrench.and.screwdriver"
        case .other: "ellipsis.bubble"
        }
    }
}

private protocol ProfileSupportSubmissionService: Sendable {
    func submit(category: ProfileIssueCategory, details: String) async -> String
}

private struct MockProfileSupportSubmissionService: ProfileSupportSubmissionService {
    func submit(category: ProfileIssueCategory, details: String) async -> String {
        try? await Task.sleep(nanoseconds: 700_000_000)
        return "MED-\(String(UUID().uuidString.prefix(8)).uppercased())"
    }
}

@ViewBuilder
private func supportHero(icon: String, titleKey: String, bodyKey: String) -> some View {
    VStack(spacing: 12) {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(AppColor.green.opacity(0.16))
            .frame(width: 68, height: 68)
            .overlay {
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(AppColor.green)
            }

        Text(titleKey.localized)
            .font(.system(size: 22, weight: .bold))
            .foregroundStyle(ProfileStyle.primaryText)
            .multilineTextAlignment(.center)

        Text(bodyKey.localized)
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(ProfileStyle.secondaryText)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
    }
    .frame(maxWidth: .infinity)
    .padding(20)
    .background(ProfileStyle.card)
    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    .overlay {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .stroke(ProfileStyle.border, lineWidth: 1)
    }
}

