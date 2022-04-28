//
//  ImagePickerView.swift
//  ink
//
//  Created by Michael Jach on 12/04/2022.
//

import SwiftUI

struct ImagePickerView: UIViewControllerRepresentable {
  @Environment(\.presentationMode) private var presentationMode
  var sourceType: UIImagePickerController.SourceType = .photoLibrary
  @Binding var selectedImage: UIImage?
  
  var onSelect: ((_ image: UIImage) -> ())?
  
  func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePickerView>) -> UIImagePickerController {
    
    let imagePicker = UIImagePickerController()
    imagePicker.allowsEditing = false
    imagePicker.sourceType = sourceType
    imagePicker.delegate = context.coordinator
    
    return imagePicker
  }
  
  func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePickerView>) {
    
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var parent: ImagePickerView
    
    init(_ parent: ImagePickerView) {
      self.parent = parent
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
      
      if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
        parent.selectedImage = image
        if let onSelect = parent.onSelect {
          onSelect(image)
        }
      }
      
      parent.presentationMode.wrappedValue.dismiss()
    }
    
  }
}
