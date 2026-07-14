//
//  ApiEndpoint.swift
//  Medsy
//
//  Created by albaraa alsayed on 17/01/1448 AH.
//

import Foundation
import Alamofire

protocol ApiEndpoint {
    var baseURL: String? { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var queryParameters: Parameters? { get }
    var headers: HTTPHeaders? { get }
    var body: Data? { get }
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
}
