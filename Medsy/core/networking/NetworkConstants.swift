//
//  NetworkConstants.swift
//  Medsy
//
//  Created by Ehab Salah on 30/06/2026.
//

import Foundation

struct Constants {
    

	static let baseURL = "http://localhost:8080/api/v1/"
    static let adminToken = SecretConstants.password
    static let apiKey = SecretConstants.apiKey
    static var customerId: String? 
}
