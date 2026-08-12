import SwiftUI

struct AiChatMarkdownText: View {
    var text: String
    
    var body: some View {
        Text(parseMarkdown(text))
            .font(MedsyFont.body())
    }
    
    private func parseMarkdown(_ text: String) -> AttributedString {
        // Minimal dependency-free markdown parser for **bold**, - bullet, 1. numbered, # headings
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
            } else if lineString.range(of: "^\\d+\\. ", options: .regularExpression) != nil {
                // Keep the numbering
            }
            
            var lineAttr = AttributedString(lineString)
            
            if isHeading {
                lineAttr.font = .system(size: 18, weight: .bold)
            } else {
                lineAttr.font = .system(size: 15)
            }
            
            // Bold Parsing: **bold**
            // Simplified handling for bold by using regular expressions to find **...**
            if let regex = try? NSRegularExpression(pattern: "\\*\\*(.*?)\\*\\*") {
                let nsRange = NSRange(lineString.startIndex..<lineString.endIndex, in: lineString)
                let matches = regex.matches(in: lineString, range: nsRange).reversed()
                
                // Process from end to start to not mess up ranges
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

#Preview {
    AiChatMarkdownText(text: "# Heading\nThis is **bold** text.\n- Bullet 1\n- Bullet 2\n1. Numbered")
        .padding()
}
