//
//  DefectController.swift
//  defecttracker
//
//  Created by Michael Rönnau on 17.05.20.
//  Copyright © 2020 Michael Rönnau. All rights reserved.
//

import Foundation
import Then
import SwiftUI

class DefectController {
    
    public static var shared = DefectController()
    
    func uploadDefect(defect: DefectData, locationId: Int) -> Promise<SyncResult>{
        return Promise { resolve, reject in
            let requestUrl = Store.shared.serverURL+"/api/defect/uploadNewDefect/" + String(locationId)
            var params = defect.getUploadParams()
            params["creationDate"] = String(defect.creationDate.millisecondsSince1970)
            params["dueDate"] = String(defect.dueDate.millisecondsSince1970)
            RequestController.shared.requestAuthorizedJson(url: requestUrl, withParams: params).then {
                (response : IdResponse) in
                //print("defect \(response.id) uploaded")
                DispatchQueue.main.async{
                    defect.id = response.id
                    defect.displayId = response.id
                }
                var promises: [Promise<SyncResult>] = Array()
                var count = 1
                for image in defect.images{
                    promises.append(ImageController.shared.uploadDefectImage(image: image, defectId: response.id, count: count))
                    count += 1
                }
                for comment in defect.comments{
                    if (comment.isNew){
                        promises.append(DefectController.shared.uploadComment(comment: comment, defectId: response.id))
                    }
                }
                Promises.whenAll(promises).then { array in
                    let result = SyncResult()
                    result.defectsUploaded = 1
                    result.addAll(results: array)
                    resolve(result)
                }
            }.onError{
                (e) in
                print(e)
                reject(e)
            }
            
        }
        
    }
    
    func uploadComment(comment: DefectCommentData, defectId: Int) -> Promise<SyncResult>{
        return Promise { resolve, reject in
            let requestUrl = Store.shared.serverURL+"/api/defect/uploadNewComment/" + String(defectId)
            var params = comment.getUploadParams()
            params["creationDate"] = String(comment.creationDate.millisecondsSince1970)
            params["defectId"] = String(defectId)
            RequestController.shared.requestAuthorizedJson(url: requestUrl, withParams: params).then {
                (response : IdResponse) in
                //print("comment \(response.id) uploaded")
                DispatchQueue.main.async{
                    comment.id = response.id
                }
                var promises: [Promise<SyncResult>] = Array()
                var count = 1
                for image in comment.images{
                    promises.append(ImageController.shared.uploadCommentImage(image: image, commentId: response.id, count: count))
                    count += 1
                }
                Promises.whenAll(promises).then { array in
                    let result = SyncResult()
                    result.commentsUploaded = 1
                    result.addAll(results: array)
                    resolve(result)
                }
            }.onError{
                (e) in
                print(e)
                reject(e)
            }
            
        }
        
    }

    
}

