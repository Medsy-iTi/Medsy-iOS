//
//  AIChatImageStore.swift
//  Medsy
//

import Foundation

public enum AIChatImageStore {
    private static var cacheDirectory: URL? {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent("AIChatImages")
    }

    public static func saveImage(_ data: Data, conversationID: Int, messageID: Int) {
        guard let directory = cacheDirectory else { return }
        
        do {
            if !FileManager.default.fileExists(atPath: directory.path) {
                try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            }
            let fileURL = directory.appendingPathComponent("chat_\(conversationID)_\(messageID).jpg")
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Failed to save chat image: \(error)")
        }
    }

    public static func loadImage(conversationID: Int, messageID: Int) -> Data? {
        guard let directory = cacheDirectory else { return nil }
        let fileURL = directory.appendingPathComponent("chat_\(conversationID)_\(messageID).jpg")
        return try? Data(contentsOf: fileURL)
    }
}
