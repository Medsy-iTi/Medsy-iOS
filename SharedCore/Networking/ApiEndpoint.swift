//
//  ApiEndpoint.swift
//  Medsy
//
//  Created by Ehab Salah on 15/07/2026.
//

import Foundation
import Alamofire

struct MultipartFormPart {
    let data: Data
    let name: String
    let fileName: String?
    let mimeType: String?

    init(
        data: Data,
        name: String,
        fileName: String? = nil,
        mimeType: String? = nil
    ) {
        self.data = data
        self.name = name
        self.fileName = fileName
        self.mimeType = mimeType
    }
}

protocol ApiEndpoint {
    var baseURL: String? { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var queryParameters: Parameters? { get }
    var headers: HTTPHeaders? { get }
    var body: Data? { get }
    var multipartFormParts: [MultipartFormPart]? { get }
    var requiresAuthentication: Bool { get }
}

extension ApiEndpoint {
    var baseURL: String? {
        return nil
    }
    
    var queryParameters: Parameters? {
        return nil
    }
    
    var headers: HTTPHeaders? {
        return ["Content-Type": "application/json"]
    }

    var requiresAuthentication: Bool {
        false
    }

    var multipartFormParts: [MultipartFormPart]? {
        nil
    }
}
