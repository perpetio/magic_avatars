//
//  ImagePickerCoordinator.swift
//  AIImage
//
//  Created by Andrew Kochulab on 18.12.2022.
//

import UIKit

final class ImagePickerCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var picker: ImagePickerView
    
    init(picker: ImagePickerView) {
        self.picker = picker
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.editedImage] as? UIImage else { return }
        
        self.picker.selectedImage = selectedImage.cgImage
        self.picker.isPresented.wrappedValue.dismiss()
    }
}
