//
//  NetworkTransport.swift
//  Medsy
//
//  Created by Ehab Salah on 17/07/2026.
//

import Alamofire
import Foundation

struct NetworkResponse {
    let data: Data?
    let statusCode: Int?
}

protocol NetworkTransportProtocol {
    func execute(_ request: URLRequest) async throws -> NetworkResponse
}

final class NetworkTransport: NetworkTransportProtocol {
    func execute(_ request: URLRequest) async throws -> NetworkResponse {
        let response = await AF.request(request)
            .serializingData()
            .response
        
        if let error = response.error, response.response == nil {
            throw error
        }
        
        return NetworkResponse(
            data: response.data,
            statusCode: response.response?.statusCode
        )
    }
}
