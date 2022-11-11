//
//  SyncResult.swift
//  defecttracker
//
//  Created by Michael Rönnau on 23.05.20.
//  Copyright © 2020 Michael Rönnau. All rights reserved.
//

import Foundation

class SyncResult: ObservableObject{
    
    @Published var defectsUploaded : Int = 0
    @Published var defectUploadErrors : Int = 0
    @Published var commentsUploaded : Int = 0
    @Published var commentUploadErrors : Int = 0
    @Published var imagesUploaded : Int = 0
    @Published var imageUploadErrors : Int = 0
    @Published var projectsLoaded : Int = 0
    @Published var projectLoadErrors : Int = 0
    @Published var imagesDownloaded : Int = 0
    @Published var imageDownloadErrors : Int = 0
    
    func add(result : SyncResult){
        defectsUploaded += result.defectsUploaded
        defectUploadErrors += result.defectUploadErrors
        commentsUploaded += result.commentsUploaded
        commentUploadErrors += result.commentUploadErrors
        imagesUploaded += result.imagesUploaded
        imageUploadErrors += result.imageUploadErrors
        projectsLoaded += result.projectsLoaded
        projectLoadErrors += result.projectLoadErrors
        imagesDownloaded += result.imagesDownloaded
        imageDownloadErrors += result.imageDownloadErrors
    }
    
    func addAll(results : Array<SyncResult>){
        for i in 0..<results.count{
            self.add(result: results[i])
        }
    }
    
    func hasErrors() -> Bool{
        imageDownloadErrors > 0
    }
    
}
