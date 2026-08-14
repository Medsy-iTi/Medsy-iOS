//
//  PharmacyAiChatMarkdownText.swift
//  Medsy-Pharmacy
//
//  Dependency-free minimal markdown renderer for AI chat responses.
//  Supports **bold**, - bullets, 1. numbered lists, # headings.

import SwiftUI

struct PharmacyAiChatMarkdownText: View {
    var text: String

    var body: some View {
        Text(parseMarkdown(text))
            .font(PharmacyColor.sans(15))
    }

    private func parseMarkdown(_ text: String) -> AttributedString {
        var attributed = AttributedString()
        let lines = text.components(separatedBy: .newlines)

        for (index, line) in lines.enumerated() {
            var lineString = line
            var isHeading = false

            if lineString.hasPrefix("# ") {
                lineString = String(lineString.dropFirst(2))
                isHeading = true
            } else if lineString.hasPrefix("- ") {
                lineString = "• " + String(lineString.dropFirst(2))
            }
            // numbered lists — keep as-is

            var lineAttr = AttributedString(lineString)
            lineAttr.font = isHeading
                ? .system(size: 18, weight: .bold)
                : .system(size: 15)

            // Bold: **bold**
            if let regex = try? NSRegularExpression(pattern: "\\*\\*(.*?)\\*\\*") {
                let nsRange = NSRange(lineString.startIndex..<lineString.endIndex, in: lineString)
                let matches = regex.matches(in: lineString, range: nsRange).reversed()
                for match in matches {
                    guard let fullRange = Range(match.range(at: 0), in: lineString),
                          let innerRange = Range(match.range(at: 1), in: lineString) else { continue }
                    let innerText = String(lineString[innerRange])
                    var boldAttr = AttributedString(innerText)
                    boldAttr.font = .system(size: isHeading ? 18 : 15, weight: .bold)
                    if let attrRange = lineAttr.range(of: String(lineString[fullRange])) {
                        lineAttr.replaceSubrange(attrRange, with: boldAttr)
                    }
                }
            }

            attributed.append(lineAttr)
            if index < lines.count - 1 {
                attributed.append(AttributedString("\n"))
            }
        }
        return attributed
    }
}
