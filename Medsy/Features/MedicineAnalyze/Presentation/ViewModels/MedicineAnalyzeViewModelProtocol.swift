//
//  MedicineAnalyzeViewModelProtocol.swift
//  Medsy
//
//  Created by Ehab Salah on 23/07/2026.
//

import Foundation
import PhotosUI
import SwiftUI

@MainActor
protocol MedicineAnalyzeViewModelProtocol: AnyObject {
    var selectedPhotoItem: PhotosPickerItem? { get set }
    var selectedImageData: Data? { get }
    var showsPhotoPicker: Bool { get set }
    var showsCamera: Bool { get set }
    var showsCameraUnavailable: Bool { get }

    func selectPhoto(_ item: PhotosPickerItem?)
    func openCamera()
    func dismissCamera()
    func dismissCameraUnavailable()
    func selectCameraImage(_ imageData: Data)
    func clearSelection()
    func analyze()
}
