//
//  MedicineAnalyzeViewModel.swift
//  Medsy
//
//  Created by Ehab Salah on 23/07/2026.
//

import Observation
import PhotosUI
import SwiftUI
import UIKit

@MainActor
@Observable
final class MedicineAnalyzeViewModel: MedicineAnalyzeViewModelProtocol {
    var selectedPhotoItem: PhotosPickerItem?
    private(set) var selectedImageData: Data?
    var showsPhotoPicker = false
    var showsCamera = false
    private(set) var showsCameraUnavailable = false
    
    func selectPhoto(_ item: PhotosPickerItem?) {
        guard let item else { return }
        
        Task {
            defer { selectedPhotoItem = nil }
            guard let imageData = try? await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: imageData),
                  let jpegData = image.jpegData(compressionQuality: 0.85) else {
                return
            }
            selectedImageData = jpegData
        }
    }
    
    func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showsCameraUnavailable = true
            return
        }
        showsCamera = true
    }
    
    func dismissCamera() {
        showsCamera = false
    }
    
    func dismissCameraUnavailable() {
        showsCameraUnavailable = false
    }
    
    func selectCameraImage(_ imageData: Data) {
        selectedImageData = imageData
        showsCamera = false
    }
    
    func clearSelection() {
        selectedImageData = nil
        selectedPhotoItem = nil
    }
    
    func analyze() {
        // UI-only feature: analysis integration will be added separately.
    }
}
