//
//  PharmacyMultipartBody.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

import Foundation

struct PharmacyMultipartBody {
    let boundary: String
    let data: Data

    init(request: CreatePharmacyRequestDTO, license: PharmacyLicenseFile) throws {
        boundary = "Boundary-\(UUID().uuidString)"
        let requestData = try JSONEncoder().encode(request)
        let safeFileName = license.fileName
            .replacingOccurrences(of: "\"", with: "_")
            .replacingOccurrences(of: "\r", with: "_")
            .replacingOccurrences(of: "\n", with: "_")
        var body = Data()

        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"pharmacyRequest\"\r\n")
        body.appendString("Content-Type: application/json\r\n\r\n")
        body.append(requestData)
        body.appendString("\r\n")

        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"license\"; filename=\"\(safeFileName)\"\r\n")
        body.appendString("Content-Type: \(license.mimeType)\r\n\r\n")
        body.append(license.data)
        body.appendString("\r\n--\(boundary)--\r\n")

        data = body
    }
}

private extension Data {
    mutating func appendString(_ string: String) {
        append(Data(string.utf8))
    }
}
