import Alamofire
import Foundation

enum PrescriptionEndpoint: ApiEndpoint {
    case analyze(imageData: Data, language: String)

    var path: String {
        "prescriptions/analyze"
    }

    var method: HTTPMethod {
        .post
    }

    var queryParameters: Parameters? {
        switch self {
        case let .analyze(_, language):
            return ["lang": language]
        }
    }

    var headers: HTTPHeaders? {
        [
            "Accept": "application/json",
            "X-AI-Api-Key": Constants.geminiKey
        ]
    }

    var body: Data? {
        nil
    }

    var multipartFormParts: [MultipartFormPart]? {
        switch self {
        case let .analyze(imageData, _):
            return [
                MultipartFormPart(
                    data: imageData,
                    name: "image",
                    fileName: "prescription.jpg",
                    mimeType: "image/jpeg"
                )
            ]
        }
    }

    var requiresAuthentication: Bool {
        true
    }
}
