//
//  DefectController.swift
//  defecttracker
//
//  Created by Michael Rönnau on 17.05.20.
//  Copyright © 2020 Michael Rönnau. All rights reserved.
//

import Foundation
import SwiftUI

class DefectController {
    
    public static var shared = DefectController()
    
    func uploadDefect(defect: DefectData, locationId: Int, syncResult: SyncResult) async throws{
        let requestUrl = Store.shared.serverURL+"/api/defect/uploadNewDefect/" + String(locationId)
        var params = defect.getUploadParams()
        params["creationDate"] = String(defect.creationDate.millisecondsSince1970)
        params["dueDate"] = String(defect.dueDate.millisecondsSince1970)
        if let response: IdResponse = try await RequestController.shared.requestAuthorizedJson(url: requestUrl, withParams: params) {
            print("defect \(response.id) uploaded")
            await MainActor.run{
                syncResult.defectsUploaded += 1
                syncResult.itemsUploaded += 1.0
            }
            defect.id = response.id
            defect.displayId = response.id
            await withTaskGroup(of: Void.self){ taskGroup in
                var count = 0
                for image in defect.images{
                    count += 1
                    do{
                        try await ImageController.shared.uploadDefectImage(image: image, defectId: response.id, count: count)
                        await MainActor.run{
                            syncResult.newElementsCount -= 1
                            syncResult.imagesUploaded += 1
                            syncResult.itemsUploaded += 1.0
                        }
                    }
                    catch{
                        print("image upload error")
                        await MainActor.run{
                            syncResult.uploadErrors += 1
                        }
                    }
                }
                for comment in defect.comments{
                    if (comment.isNew){
                        do{
                            try await uploadComment(comment: comment, defectId: response.id, syncResult: syncResult)
                        }
                        catch{
                            await MainActor.run{
                                syncResult.uploadErrors += 1
                            }
                        }
                    }
                }
            }
        }
        else{
            await MainActor.run{
                syncResult.uploadErrors += 1
            }
            throw "defect upload error"
        }
    }
    
    func uploadComment(comment: DefectCommentData, defectId: Int, syncResult: SyncResult) async throws{
        let requestUrl = Store.shared.serverURL+"/api/defect/uploadNewComment/" + String(defectId)
        var params = comment.getUploadParams()
        params["creationDate"] = String(comment.creationDate.millisecondsSince1970)
        params["defectId"] = String(defectId)
        if let response: IdResponse = try await RequestController.shared.requestAuthorizedJson(url: requestUrl, withParams: params) {
            print("comment \(response.id) uploaded")
            await MainActor.run{
                syncResult.commentsUploaded += 1
                syncResult.itemsUploaded += 1.0
            }
            comment.id = response.id
            var count = 0
            for image in comment.images{
                count += 1
                do{
                    try await ImageController.shared.uploadCommentImage(image: image, commentId: response.id, count: count)
                    await MainActor.run{
                        syncResult.newElementsCount -= 1
                        syncResult.imagesUploaded += 1
                        syncResult.itemsUploaded += 1.0
                    }
                }
                catch{
                    await MainActor.run{
                        syncResult.uploadErrors += 1
                    }
                }
            }
        }
        else{
            await MainActor.run{
                syncResult.uploadErrors += 1
            }
            throw "comment upload error"
        }
    }
    
}

