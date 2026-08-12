//
//  CompleteRequestEndpoint.swift
//  Medsy
//
//  Created by Ehab Salah on 24/07/2026.
//

import Alamofire
import Foundation

enum CompleteRequestEndpoint: ApiEndpoint {
    case submit(CompleteRequestDTO)

    var path: String {
        "requests"
    }

    var method: HTTPMethod {
        .post
    }

    var headers: HTTPHeaders? {
        ["Accept": "application/json"]
    }
    var body: Data? {
        nil
    }

    var multipartFormParts: [MultipartFormPart]? {
        switch self {
        case let .submit(request):
            guard let requestData = try? JSONEncoder().encode(request) else {
                return nil
            }

            var parts = [
                MultipartFormPart(
                    data: requestData,
                    name: "request",
                    mimeType: "application/json"
                )
            ]

            if let prescriptionData = request.prescriptionData {
                parts.append(
                    MultipartFormPart(
                        data: prescriptionData,
                        name: "prescription",
                        fileName: "prescription.jpg",
                        mimeType: "image/jpeg"
                    )
                )
            }
            return parts
        }
    }

    var requiresAuthentication: Bool {
        true
    }

    var allowsResponseLogging: Bool {
        true
    }
}
