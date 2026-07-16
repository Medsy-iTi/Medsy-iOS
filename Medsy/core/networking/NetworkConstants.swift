//
//  NetworkConstants.swift
//  Medsy
//
//  Created by Ehab Salah on 30/06/2026.
//

import Foundation

struct Constants {
    
    static var baseURL: String {
        return "https://\(SecretConstants.apiKey):\(SecretConstants.password)@\(SecretConstants.hostname)/admin/api/2026-01/"
    }
	static let productsBaseURL = "http://localhost:8080/api/v1/"
    static let adminToken = SecretConstants.password
    static let apiKey = SecretConstants.apiKey
    static var customerId: String? 
}
