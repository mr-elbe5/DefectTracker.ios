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
    
    func uploadDefect(defect: DefectData, locationId: Int, callback: @escaping (Bool) -> Void){
        let requestUrl = Store.shared.serverURL+"/api/defect/uploadNewDefect/" + String(locationId)
        var params = defect.getUploadParams()
        params["creationDate"] = String(defect.creationDate.millisecondsSince1970)
        params["dueDate"] = String(defect.dueDate.millisecondsSince1970)
        RequestController.shared.requestAuthorizedJson(url: requestUrl, withParams: params) { (result: IdResponse?, error) in
            if let result = result{
                //print("defect \(response.id) uploaded")
                DispatchQueue.main.async{
                    defect.id = result.id
                    defect.displayId = result.id
                }
                if defect.images.count == 0 && defect.comments.count == 0{
                    callback(true)
                }
                else{
                    var imgcount = 0
                    var cbcount = 0
                    for image in defect.images{
                        ImageController.shared.uploadDefectImage(image: image, defectId: result.id, count: imgcount){ success in
                            if success{
                                imgcount += 1
                                if imgcount + cbcount == defect.images.count + defect.comments.count{
                                    callback(true)
                                }
                            }
                            else{
                                callback(false)
                            }
                        }
                    }
                    for comment in defect.comments{
                        if (comment.isNew){
                            DefectController.shared.uploadComment(comment: comment, defectId: result.id){ success in
                                if success{
                                    cbcount += 1
                                    if imgcount + cbcount == defect.images.count + defect.comments.count{
                                        callback(true)
                                    }
                                }
                                else{
                                    callback(false)
                                }
                            }
                        }
                    }
                }
            }
            else{
                print("upload defect error")
                callback(false)
            }
        }
        
    }
    
    func uploadComment(comment: DefectCommentData, defectId: Int, callback: @escaping (Bool) -> Void){
        let requestUrl = Store.shared.serverURL+"/api/defect/uploadNewComment/" + String(defectId)
        var params = comment.getUploadParams()
        params["creationDate"] = String(comment.creationDate.millisecondsSince1970)
        params["defectId"] = String(defectId)
        RequestController.shared.requestAuthorizedJson(url: requestUrl, withParams: params) { (result: IdResponse?, error) in
            if let result = result{
                //print("comment \(response.id) uploaded")
                DispatchQueue.main.async{
                    comment.id = result.id
                }
                if comment.images.count == 0{
                    callback(true)
                }
                else{
                    var count = 0
                    for image in comment.images{
                        ImageController.shared.uploadCommentImage(image: image, commentId: result.id, count: count){ success in
                            if success{
                                count += 1
                                if count == comment.images.count{
                                    callback(true)
                                }
                            }
                            else{
                                callback(false)
                            }
                        }
                    }
                }
            }
            else{
                print("upload defect comment error")
                callback(false)
            }
        }
        
    }

    
}

