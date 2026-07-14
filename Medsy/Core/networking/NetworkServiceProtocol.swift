//
//  NetworkServiceProtocol.swift
//  Medsy
//
//  Created by Ahmed Elkady on 13/07/2026.
//

import Foundation

protocol NetworkServiceProtocol {
    func request<T: Decodable>(endpoint: ApiEndpoint) async throws -> T
}
