//
//  OpenChatbotPromptEnvironment.swift
//  Medsy
//
//  Created by Ahmed Elkady on 12/08/2026.
//

import SwiftUI

private struct OpenChatbotPromptKey: EnvironmentKey {
    static let defaultValue: ((String) -> Void)? = nil
}

extension EnvironmentValues {
    var openChatbotPrompt: ((String) -> Void)? {
        get { self[OpenChatbotPromptKey.self] }
        set { self[OpenChatbotPromptKey.self] = newValue }
    }
}
