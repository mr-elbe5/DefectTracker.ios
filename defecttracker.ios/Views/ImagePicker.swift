//
//  ImagePicker.swift
//  test.ios
//
//  Created by Michael Rönnau on 12.04.20.
//  Copyright © 2020 Michael Rönnau. All rights reserved.
//

import Foundation
import SwiftUI

struct ImagePickerView: View {

    @Binding var showImagePicker: Bool
    @Binding var sourceType : UIImagePickerController.SourceType
    @Binding var imageList: [ImageData]

    var body: some View {
        ImagePicker(isShown: $showImagePicker, sourceType: $sourceType, imageList: $imageList)
    }
}

class ImagePickerCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @Binding var isShown: Bool
    @Binding var sourceType : UIImagePickerController.SourceType
    @Binding var imageList: [ImageData]

    init(isShown: Binding<Bool>, sourceType: Binding<UIImagePickerController.SourceType>, imageList: Binding<[ImageData]>) {
        _isShown = isShown
        _sourceType = sourceType
        _imageList = imageList
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        let resizedImage = ImageController.shared.resizeImage(uiImage: pickedImage, maxWidth: Statics.maxImageEdge, maxHeight: Statics.maxImageEdge)
        let data = ImageController.shared.savedPickedImage(uiImage: resizedImage)
        imageList.append(data)
        isShown = false
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        isShown = false
    }
}

struct ImagePicker: UIViewControllerRepresentable {

    @Binding var isShown: Bool
    @Binding var sourceType : UIImagePickerController.SourceType
    @Binding var imageList: [ImageData]

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {

    }

    func makeCoordinator() -> ImagePickerCoordinator {
        return ImagePickerCoordinator(isShown: $isShown, sourceType: $sourceType, imageList: $imageList)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        if self.sourceType == .camera && UIImagePickerController.isSourceTypeAvailable(.camera){
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }
        return picker
    }

}

struct ImagePicker_Previews: PreviewProvider {
    @State static var isShown = true
    @State static var sourceType : UIImagePickerController.SourceType = .camera
    @State static var images : [ImageData] = []
    static var previews: some View {
        ImagePickerView(showImagePicker: $isShown, sourceType: $sourceType, imageList: $images)
    }
}
