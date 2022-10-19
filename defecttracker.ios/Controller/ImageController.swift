//
//  ImageController.swift
//  test.ios
//
//  Created by Michael Rönnau on 04.04.20.
//  Copyright © 2020 Michael Rönnau. All rights reserved.
//

import Foundation
import SwiftUI
import Then

class ImageController{
    
    public static var shared = ImageController()
    
    func getImage(image : ImageData) -> UIImage{
        if (DocumentStore.shared.fileExists(fileName: image.getLocalFileName())){
            if let uiImage = DocumentStore.shared.readImage(name: image.getLocalFileName()){
                return uiImage
            }
        }
        return UIImage(imageLiteralResourceName: "placeholder")
    }
    
    func loadImage(image : ImageData) -> Promise<UIImage>{
        return Promise{ resolve, reject in
            //print("start loading image \(image.id)")
            if (DocumentStore.shared.fileExists(fileName: image.getLocalFileName())){
                //print("file exists")
                let uiImage = DocumentStore.shared.readImage(name: image.getLocalFileName())
                resolve(uiImage!)
            }
            else{
                //print("file needs downloading")
                let serverUrl = Store.shared.serverURL+"/api/image/download/" + String(image.id)
                let params = [
                    "scale" : "100"
                ]
                RequestController.shared.requestAuthorizedImage(url: serverUrl, withParams: params).then {
                    (img : UIImage) in
                    //print("received image \(image.id) for \(image.getLocalFileName())")
                    DocumentStore.shared.saveImage(image: img, name: image.getLocalFileName())
                    resolve(img)
                }.onError {err in
                    reject(err)
                }
            }
        }
    }
    
    func loadProjectImage(image : ImageData) -> Promise<Bool>{
        return Promise{ resolve, reject in
            if (DocumentStore.shared.fileExists(fileName: image.getLocalFileName())){
                //print("file exists")
                resolve(false)
            }
            else{
                //print("file needs downloading")
                let serverUrl = Store.shared.serverURL+"/api/image/download/" + String(image.id)
                let params = [
                    "scale" : "100"
                ]
                RequestController.shared.requestAuthorizedImage(url: serverUrl, withParams: params).then {
                    (img : UIImage) in
                    DocumentStore.shared.saveImage(image: img, name: image.getLocalFileName())
                    resolve(true)
                }.onError {err in
                    reject(err)
                }
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
    
    func loadImage(data: ImageData){
        if data.id == 0 {
            return
        }
        //print("loading image \(data.id)")
        ImageController.shared.loadImage(image: data).then{
            (uiImage : UIImage) in
            
        }
    }
    
    
    func uploadDefectImage(image: ImageData, defectId: Int, count: Int) -> Promise<SyncResult>{
        return Promise { resolve, reject in
            let requestUrl = Store.shared.serverURL+"/api/defect/uploadNewDefectImage/" + String(defectId)
            let newFileName = "img-\(defectId)-\(count).jpg"
            let uiImage = ImageController.shared.getImage(image: image)
            RequestController.shared.uploadAuthorizedImage(url: requestUrl, withImage: uiImage, fileName: newFileName).then {
                (response : IdResponse) in
                //print("defect image uploaded with id \(response.id)")
                DispatchQueue.main.async{
                    image.id = response.id
                }
                let result = SyncResult()
                result.imagesUploaded += 1
                resolve(result)
            }
        }
    }
    
    func uploadCommentImage(image: ImageData, commentId: Int, count: Int) -> Promise<SyncResult>{
        return Promise { resolve, reject in
            let requestUrl = Store.shared.serverURL+"/api/defect/uploadNewCommentImage/" + String(commentId)
            let newFileName = "img-\(commentId)-\(count).jpg"
            let uiImage = ImageController.shared.getImage(image: image)
            RequestController.shared.uploadAuthorizedImage(url: requestUrl, withImage: uiImage, fileName: newFileName).then {
                (response : IdResponse) in
                //print("comment image uploaded with id \(response.id)")
                DispatchQueue.main.async{
                    image.id = response.id
                }
                let result = SyncResult()
                result.imagesUploaded += 1
                resolve(result)
            }
        }
    }
    
}


