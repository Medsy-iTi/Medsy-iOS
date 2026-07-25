//
//  CompleteRequestEndpoint.swift
//  Medsy
//
//  Created by Ehab Salah on 24/07/2026.
//

import Alamofire
import Foundation

enum CompleteRequestEndpoint: ApiEndpoint {
    case submit(CompleteRequestDTO, imageData: Data? = nil)

    var path: String {
        "requests"
    }

    var method: HTTPMethod {
        .post
    }

    var headers: HTTPHeaders? {
        nil
    }

    // OLD:
    // var body: Data? {
    //     switch self {
    //     case let .submit(request):
    //         try? JSONEncoder().encode(request)
    //     }
    // }

    var body: Data? {
        nil
    }

    var multipartFormParts: [MultipartFormPart]? {
        switch self {
        case let .submit(request, imageData):
            var parts: [MultipartFormPart] = []
            if let requestData = try? JSONEncoder().encode(request) {
                parts.append(
                    MultipartFormPart(
                        data: requestData,
                        name: "request",
                        fileName: "request.json",
                        mimeType: "application/json"
                    )
                )
            }
            if let imageData {
                parts.append(
                    MultipartFormPart(
                        data: imageData,
                        name: "file",
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
}
