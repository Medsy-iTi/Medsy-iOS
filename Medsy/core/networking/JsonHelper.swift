//
//  Helper.swift
//  Medsy
//
//  Created by Ehab Salah on 01/07/2026.
//

import Foundation

enum JsonHelper {
    static func prettyJSON(_ data: Data) -> String {
        guard let object = try? JSONSerialization.jsonObject(with: data),
              let prettyData = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys]),
              let string = String(data: prettyData, encoding: .utf8) else {
            return String(data: data, encoding: .utf8) ?? "Invalid JSON"
        }
        return string
    }
}
