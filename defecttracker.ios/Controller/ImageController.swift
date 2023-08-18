//
//  ImageController.swift
//  test.ios
//
//  Created by Michael Rönnau on 04.04.20.
//  Copyright © 2020 Michael Rönnau. All rights reserved.
//

import Foundation
import SwiftUI

class ImageController{
    
    public static var shared = ImageController()
    
    func getImage(image : ImageData) -> UIImage{
        //print("get image")
        if (DocumentStore.shared.fileExists(fileName: image.getLocalFileName())){
            if let uiImage = DocumentStore.shared.readImage(name: image.getLocalFileName()){
                //print("return uiimage")
                return uiImage
            }
        }
        //print("return placeholder")
        return UIImage(imageLiteralResourceName: "placeholder")
    }
    
    func loadImage(image : ImageData) async -> UIImage?{
        //print("start loading image \(image.id)")
        if (DocumentStore.shared.fileExists(fileName: image.getLocalFileName())){
            let uiImage = DocumentStore.shared.readImage(name: image.getLocalFileName())
            return uiImage
        }
        //print("file needs downloading")
        let serverUrl = Store.shared.serverURL+"/api/image/download/" + String(image.id)
        let params = [
            "scale" : "100"
        ]
        do{
            if let img = try await RequestController.shared.requestAuthorizedImage(url: serverUrl, withParams: params) {
                //print("received image \(image.id) for \(image.getLocalFileName())")
                DocumentStore.shared.saveImage(image: img, name: image.getLocalFileName())
                return img
            }
        }
        catch{
            print("file load error")
        }
        return nil
    }
    
    func loadProjectImage(image : ImageData, syncResult: SyncResult) async throws{
        if (DocumentStore.shared.fileExists(fileName: image.getLocalFileName())){
            await MainActor.run{
                syncResult.imagesPresent += 1
            }
            return
        }
        //print("file needs downloading")
        let serverUrl = Store.shared.serverURL+"/api/image/download/" + String(image.id)
        let params = [
            "scale" : "100"
        ]
        if let img = try await RequestController.shared.requestAuthorizedImage(url: serverUrl, withParams: params) {
            DocumentStore.shared.saveImage(image: img, name: image.getLocalFileName())
            await MainActor.run{
                syncResult.imagesLoaded += 1
            }
        }
        else{
            await MainActor.run{
                syncResult.downloadErrors += 1
            }
        }
    }
    
    func savedPickedImage(uiImage : UIImage) -> ImageData{
        let data = ImageData()
        data.id = Store.shared.getNextId()
        data.fileName = "photo.jpeg"
        data.contentType = "image/jpeg"
        data.width = Int(uiImage.size.width)
        data.height = Int(uiImage.size.height)
        data.displayName = "photo"
        DocumentStore.shared.saveImage(image: uiImage, name: data.getLocalFileName())
        return data
    }
    
    func resizeImage(uiImage: UIImage,maxWidth: CGFloat, maxHeight: CGFloat) -> UIImage{
        if (uiImage.size.width<=maxWidth || maxWidth==0) && (uiImage.size.height<=maxHeight || maxHeight==0) {
            return uiImage
        }
        let widthRatio = maxWidth==0 ? 1 : maxWidth/uiImage.size.width
        let heightRatio = maxHeight==0 ? 1 : maxHeight/uiImage.size.height
        let ratio = min(widthRatio,heightRatio)
        let newSize = CGSize(width: uiImage.size.width*ratio, height: uiImage.size.height*ratio)
        return resizeImage(uiImage: uiImage, size: newSize)
    }
    
    func resizeImage(uiImage: UIImage,size: CGSize) -> UIImage{
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image{ (context) in
            uiImage.draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    func uploadDefectImage(image: ImageData, defectId: Int, count: Int) async throws{
        let requestUrl = Store.shared.serverURL+"/api/defect/uploadNewDefectImage/" + String(defectId) + "?imageId=" + String(image.id)
        let newFileName = "img-\(defectId)-\(count).jpg"
        //print("get image \(newFileName)")
        let uiImage = ImageController.shared.getImage(image: image)
        if let response = try await RequestController.shared.uploadAuthorizedImage(url: requestUrl, withImage: uiImage, fileName: newFileName) {
            print("defect image uploaded with id \(response.id)")
            image.id = response.id
        }
        else{
            throw "image upload error"
        }
    }
    
    func uploadCommentImage(image: ImageData, commentId: Int, count: Int) async throws{
        let requestUrl = Store.shared.serverURL+"/api/defect/uploadNewCommentImage/" + String(commentId) + "?imageId=" + String(image.id)
        let newFileName = "img-\(commentId)-\(count).jpg"
        let uiImage = ImageController.shared.getImage(image: image)
        if let response = try await RequestController.shared.uploadAuthorizedImage(url: requestUrl, withImage: uiImage, fileName: newFileName) {
            print("comment image uploaded with id \(response.id)")
            image.id = response.id
        }
        else{
            throw "image upload error"
        }
    }
    
}


