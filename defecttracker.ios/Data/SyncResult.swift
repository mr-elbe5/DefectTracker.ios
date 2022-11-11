//
//  SyncResult.swift
//  defecttracker
//
//  Created by Michael Rönnau on 23.05.20.
//  Copyright © 2020 Michael Rönnau. All rights reserved.
//

import Foundation
import SwiftUI

class SyncResult: ObservableObject{
    
    @Published var defectsUploaded : Int = 0
    @Published var commentsUploaded : Int = 0
    @Published var imagesUploaded : Int = 0
    @Published var projectsLoaded : Int = 0
    @Published var imagesDownloaded : Int = 0
    
    func add(result : SyncResult){
        defectsUploaded += result.defectsUploaded
        commentsUploaded += result.commentsUploaded
        imagesUploaded += result.imagesUploaded
        projectsLoaded += result.projectsLoaded
        imagesDownloaded += result.imagesDownloaded
    }
    
    func addAll(results : Array<SyncResult>){
        for i in 0..<results.count{
            self.add(result: results[i])
        }
    }
    
}
