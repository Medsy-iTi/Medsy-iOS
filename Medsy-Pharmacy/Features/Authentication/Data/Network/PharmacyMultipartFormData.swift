import Foundation

struct PharmacyMultipartFormData {
    let boundary: String
    let body: Data

    init(request: CreatePharmacyRequestDTO, license: PharmacyLicenseDocument) throws {
        boundary = "MedsyBoundary-\(UUID().uuidString)"

        var data = Data()
        let requestData = try JSONEncoder().encode(request)

        data.appendUTF8("--\(boundary)\r\n")
        data.appendUTF8("Content-Disposition: form-data; name=\"pharmacyRequest\"\r\n")
        data.appendUTF8("Content-Type: application/json\r\n\r\n")
        data.append(requestData)
        data.appendUTF8("\r\n")

        let safeFileName = license.fileName
            .replacingOccurrences(of: "\"", with: "")
            .replacingOccurrences(of: "\r", with: "")
            .replacingOccurrences(of: "\n", with: "")

        data.appendUTF8("--\(boundary)\r\n")
        data.appendUTF8("Content-Disposition: form-data; name=\"license\"; filename=\"\(safeFileName)\"\r\n")
        data.appendUTF8("Content-Type: application/pdf\r\n\r\n")
        data.append(license.data)
        data.appendUTF8("\r\n--\(boundary)--\r\n")

        body = data
    }
}

private extension Data {
    mutating func appendUTF8(_ value: String) {
        append(Data(value.utf8))
    }
}
