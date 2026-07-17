//
//  APIErrorResponse.swift
//  Medsy
//
//  Created by Ehab Salah on 17/07/2026.
//


struct APIErrorResponse: Decodable {
    let success: Bool
    let message: String
}