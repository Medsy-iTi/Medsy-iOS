//
//  PharmacyAIDashboardSummaryCard.swift
//  Medsy-Pharmacy
//

import SwiftUI

struct PharmacyAIDashboardSummaryCard: View {
    let state: PharmacyHomeViewModel.AISummaryState

    var body: some View {
        switch state {
        case .idle, .restricted:
            EmptyView()

        case .loading:
            loadingView
                .padding(PharmacySpacing.md)
                .background(cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: PharmacyRadius.md))
                .overlay(cardBorder)

        case .failed(let message):
            failedView(message: message)
                .padding(PharmacySpacing.md)
                .background(cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: PharmacyRadius.md))
                .overlay(cardBorder)

        case .loaded(let summary):
            contentView(summary: summary)
                .padding(PharmacySpacing.md)
                .background(cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: PharmacyRadius.md))
                .overlay(cardBorder)
        }
    }

    private var cardBackground: some View {
        ZStack {
            PharmacyColor.card

            LinearGradient(
                colors: [
                    PharmacyColor.primary.opacity(0.06),
                    PharmacyColor.primary.opacity(0.01)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: PharmacyRadius.md)
            .stroke(PharmacyColor.primary.opacity(0.18), lineWidth: 1)
    }

    private var headerView: some View {
        HStack(spacing: PharmacySpacing.sm) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                PharmacyColor.primary.opacity(0.2),
                                PharmacyColor.primary.opacity(0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 32, height: 32)

                Image(systemName: "sparkles")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(PharmacyColor.primary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("pharmacy.home.ai_summary_title".localized)
                    .font(PharmacyColor.sans(15, .bold))
                    .foregroundStyle(PharmacyColor.textPrimary)
            }

            Spacer()

            HStack(spacing: 4) {
                Circle()
                    .fill(PharmacyColor.primary)
                    .frame(width: 6, height: 6)

                Text("pharmacy.home.ai_badge".localized)
                    .font(PharmacyColor.sans(10, .bold))
                    .foregroundStyle(PharmacyColor.primary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(PharmacyColor.primary.opacity(0.1))
            )
        }
    }

    private var loadingView: some View {
        VStack(alignment: .leading, spacing: PharmacySpacing.sm) {
            headerView

            VStack(alignment: .leading, spacing: PharmacySpacing.xs + 2) {
                ForEach(0..<3, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(PharmacyColor.textSecondary.opacity(0.12))
                        .frame(height: 14)
                        .frame(maxWidth: index == 2 ? 180 : .infinity)
                }
            }
            .padding(.top, PharmacySpacing.xs)
        }
    }

    private func failedView(message: String) -> some View {
        VStack(alignment: .leading, spacing: PharmacySpacing.sm) {
            headerView

            HStack(spacing: PharmacySpacing.xs) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(PharmacyColor.warning)

                Text(message)
                    .font(PharmacyColor.sans(13))
                    .foregroundStyle(PharmacyColor.textSecondary)
            }
            .padding(.vertical, 4)
        }
    }

    private func contentView(summary: AIDashboardSummary) -> some View {
        VStack(alignment: .leading, spacing: PharmacySpacing.sm) {
            headerView

            Divider()
                .background(PharmacyColor.primary.opacity(0.1))
                .padding(.vertical, 2)

            sentencesView(for: summary.summary)

            if let generatedAt = summary.generatedAt {
                HStack(spacing: 4) {
                    Image(systemName: "calendar.clock")
                        .font(.system(size: 10))
                    Text(formattedDate(generatedAt))
                        .font(PharmacyColor.sans(11, .medium))
                    Spacer()
                }
                .foregroundStyle(PharmacyColor.textSecondary.opacity(0.8))
                .padding(.top, 4)
            }
        }
    }

    private func sentencesView(for text: String) -> some View {
        let sentences = extractSentences(text)

        return VStack(alignment: .leading, spacing: PharmacySpacing.xs + 4) {
            ForEach(Array(sentences.enumerated()), id: \.offset) { _, sentence in
                HStack(alignment: .top, spacing: PharmacySpacing.xs + 2) {
                    Circle()
                        .fill(PharmacyColor.primary)
                        .frame(width: 6, height: 6)
                        .padding(.top, 6)

                    formattedText(sentence)
                }
            }
        }
    }

    private func extractSentences(_ text: String) -> [String] {
        let normalized = text
            .replacingOccurrences(of: "\r\n", with: "\n")

        let lines = normalized.components(separatedBy: "\n")
        var sentences: [String] = []

        // Match period followed by whitespace, but NOT when preceded and followed by digits (e.g. 7836.50)
        let regex = try? NSRegularExpression(pattern: #"(?<!\d)\.(?!\d)\s*"#)

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty { continue }

            let nsString = trimmed as NSString
            let matches = regex?.matches(in: trimmed, range: NSRange(location: 0, length: nsString.length)) ?? []

            if matches.isEmpty {
                sentences.append(trimmed)
            } else {
                var lastLocation = 0
                for match in matches {
                    let range = match.range
                    let sentenceLength = range.location - lastLocation
                    if sentenceLength > 0 {
                        let sentencePart = nsString.substring(with: NSRange(location: lastLocation, length: sentenceLength)).trimmingCharacters(in: .whitespacesAndNewlines)
                        if !sentencePart.isEmpty {
                            sentences.append(sentencePart.hasSuffix(".") ? sentencePart : "\(sentencePart).")
                        }
                    }
                    lastLocation = range.location + range.length
                }

                if lastLocation < nsString.length {
                    let remainder = nsString.substring(from: lastLocation).trimmingCharacters(in: .whitespacesAndNewlines)
                    if !remainder.isEmpty {
                        sentences.append(remainder.hasSuffix(".") ? remainder : "\(remainder).")
                    }
                }
            }
        }

        return sentences.isEmpty ? [text] : sentences
    }

    private func formattedText(_ text: String) -> some View {
        let formattedStr: AttributedString = {
            let options = AttributedString.MarkdownParsingOptions(
                allowsExtendedAttributes: true,
                interpretedSyntax: .full
            )
            if let attributed = try? AttributedString(markdown: text, options: options) {
                return attributed
            }
            return AttributedString(text)
        }()

        return Text(formattedStr)
            .font(PharmacyColor.sans(14, .regular))
            .foregroundStyle(PharmacyColor.textPrimary)
            .lineSpacing(3)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: LanguageManager.shared.languageCode)
        return formatter.string(from: date)
    }
}
