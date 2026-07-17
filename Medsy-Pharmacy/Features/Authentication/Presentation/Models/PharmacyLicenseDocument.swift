//
//  PharmacyLicenseDocument.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

import Foundation

struct PharmacyLicenseDocument: Equatable {
    static let maximumByteCount = 10 * 1024 * 1024

    let name: String
    let data: Data

    var byteCount: Int {
        data.count
    }

    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: Int64(byteCount), countStyle: .file)
    }

    init(url: URL) throws {
        let hasAccess = url.startAccessingSecurityScopedResource()
        defer {
            if hasAccess {
                url.stopAccessingSecurityScopedResource()
            }
        }

        let resourceValues = try url.resourceValues(forKeys: [.fileSizeKey, .nameKey])
        let fileSize = resourceValues.fileSize ?? 0

        guard url.pathExtension.lowercased() == "pdf" else {
            throw PharmacyLicenseDocumentError.invalidType
        }

        guard fileSize > 0 else {
            throw PharmacyLicenseDocumentError.emptyFile
        }

        guard fileSize <= Self.maximumByteCount else {
            throw PharmacyLicenseDocumentError.fileTooLarge
        }

        let data = try Data(contentsOf: url, options: .mappedIfSafe)
        guard data.starts(with: [0x25, 0x50, 0x44, 0x46]) else {
            throw PharmacyLicenseDocumentError.invalidPDF
        }

        self.name = resourceValues.name ?? url.lastPathComponent
        self.data = data
    }
}

enum PharmacyLicenseDocumentError: Error {
    case invalidType
    case emptyFile
    case fileTooLarge
    case invalidPDF

    var localizedMessage: String {
        switch self {
        case .invalidType:
            "pharmacy.auth.license.error.type".localized
        case .emptyFile:
            "pharmacy.auth.license.error.empty".localized
        case .fileTooLarge:
            "pharmacy.auth.license.error.size".localized
        case .invalidPDF:
            "pharmacy.auth.license.error.invalid".localized
        }
    }
}
