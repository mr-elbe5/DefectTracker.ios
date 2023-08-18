//
//  SyncResult.swift
//  defecttracker
//
//  Created by Michael Rönnau on 23.05.20.
//  Copyright © 2020 Michael Rönnau. All rights reserved.
//

import Foundation

@MainActor
class SyncResult: ObservableObject{
    
    @Published var defectsUploaded : Int = 0
    @Published var commentsUploaded : Int = 0
    @Published var imagesUploaded : Int = 0
    @Published var imagesPresent : Int = 0
    
    @Published var projectsLoaded : Int = 0
    @Published var locationsLoaded : Int = 0
    @Published var defectsLoaded : Int = 0
    @Published var imagesLoaded : Int = 0
    
    @Published var uploadErrors : Int = 0
    @Published var downloadErrors : Int = 0
    
    @Published var itemsUploaded: Double = 0.0
    @Published var downloadProgress: Double = 0.0
    
    @Published var newElementsCount: Int = 0
    
    func hasErrors() -> Bool{
        uploadErrors > 0 || downloadErrors > 0
    }
    
    func reset(){
        defectsUploaded = 0
        commentsUploaded = 0
        imagesUploaded = 0
        imagesPresent = 0
        itemsUploaded = 0
        
        projectsLoaded = 0
        locationsLoaded = 0
        defectsLoaded = 0
        imagesLoaded = 0
        
        uploadErrors = 0
        downloadErrors = 0
        
    }
    
}
