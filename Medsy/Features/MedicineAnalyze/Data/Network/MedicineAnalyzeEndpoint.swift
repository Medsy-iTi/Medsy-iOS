//
//  MedicineAnalyzeEndpoint.swift
//  Medsy
//
//  Created by Ehab Salah on 23/07/2026.
//

import Alamofire
import Foundation

enum MedicineAnalyzeEndpoint: ApiEndpoint {
    case analyze(imageData: Data, language: String)

    var path: String {
        "products/analyze-image"
    }

    var method: HTTPMethod {
        .post
    }

    var queryParameters: Parameters? {
        switch self {
        case let .analyze(_, language):
            ["lang": language]
        }
    }

    var headers: HTTPHeaders? {
        [
            "Accept": "application/json",
            "X-AI-Api-Key": Constants.aiKey
        ]
    }

    var body: Data? {
        nil
    }

    var multipartFormParts: [MultipartFormPart]? {
        switch self {
        case let .analyze(imageData, _):
            [
                MultipartFormPart(
                    data: imageData,
                    name: "image",
                    fileName: "medicine.jpg",
                    mimeType: "image/jpeg"
                )
            ]
        }
    }

    var requiresAuthentication: Bool {
        true
    }
}
