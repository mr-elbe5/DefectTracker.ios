//
//  ProjectController.swift
//  defecttracker
//
//  Created by Michael Rönnau on 15.04.20.
//  Copyright © 2020 Michael Rönnau. All rights reserved.
//

import Foundation
import SwiftUI

class ProjectController {
    
    public static var shared = ProjectController()
    
    func loadProjects(syncResult: SyncResult){
        let requestUrl = Store.shared.serverURL+"/api/project/getProjects"
        let params = Dictionary<String,String>()
        Task{
            do{
                if let projectList: ProjectList = try await RequestController.shared.requestAuthorizedJson(url: requestUrl, withParams: params) {
                    print(projectList)
                    syncResult.projectsLoaded = projectList.projects.count
                    try await self.loadProjectImages(data: projectList, syncResult: syncResult)
                    print("saving project list")
                    Store.shared.setProjectList(data: projectList)
                }
            }
            catch {
                syncResult.projectLoadErrors += 1
                print("error loading projects")
            }
        }
    }
    
    func clearProjects(){
            Store.shared.setProjectList(data: ProjectList())
            self.clearProjectImages()
    }
    
    func loadProjectImages(data: ProjectList, syncResult: SyncResult) async throws{
        print("start loading images")
        await withTaskGroup(of: Bool.self){ taskGroup in
            for project in data.projects{
                for location in project.locations{
                    if location.plan != nil {
                        taskGroup.addTask{
                            do{
                                return try await ImageController.shared.loadProjectImage(image: location.plan!)
                            }
                            catch{
                                return false
                            }
                        }
                    }
                    for defect in location.defects{
                        for image in defect.images{
                            taskGroup.addTask{
                                do{
                                    return try await ImageController.shared.loadProjectImage(image: image)
                                }
                                catch{
                                    return false
                                }
                            }
                        }
                        for comment in defect.comments{
                            for image in comment.images{
                                taskGroup.addTask{
                                    do{
                                        return try await ImageController.shared.loadProjectImage(image: image)
                                    }
                                    catch{
                                        return false
                                    }
                                }
                            }
                        }
                    }
                }
            }
            for await success in taskGroup {
                if success{
                    syncResult.imagesDownloaded += 1
                }
                else{
                    syncResult.imageDownloadErrors += 1
                }
            }
        }
    }
    
    func clearProjectImages(){
        DocumentStore.shared.clearFiles()
    }
    
    func countNewElements() -> Int {
        var count = 0
        for project in Store.shared.projectList.projects{
            for location in project.locations{
                for defect in location.defects{
                    if defect.isNew{
                        count += 1
                    }
                    for comment in defect.comments{
                        if comment .isNew{
                            count += 1
                        }
                    }
                }
            }
        }
        return count
    }
    
    func uploadNewItems(syncResult: SyncResult) {
        Task{
            let projects = Store.shared.projectList
            await withTaskGroup(of: Void.self){ taskGroup in
                for project in projects.projects{
                    for location in project.locations{
                        for defect in location.defects{
                            if (defect.isNew){
                                taskGroup.addTask{
                                    do{
                                        try await DefectController.shared.uploadDefect(defect: defect, locationId: location.id, syncResult: syncResult)
                                    }
                                    catch{
                                        syncResult.defectUploadErrors += 1
                                    }
                                }
                            }
                            else{
                                for comment in defect.comments{
                                    if (comment.isNew){
                                        taskGroup.addTask{
                                            do{
                                                try await DefectController.shared.uploadComment(comment: comment, defectId: defect.id, syncResult: syncResult)
                                            }
                                            catch{
                                                syncResult.commentUploadErrors += 1
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    func synchronize(syncResult: SyncResult){
        ProjectController.shared.uploadNewItems(syncResult: syncResult)
        ProjectController.shared.loadProjects(syncResult: syncResult)
    }
    
}
