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
    
    func loadProjects(syncResult: SyncResult) async{
        let requestUrl = Store.shared.serverURL+"/api/project/getProjects"
        let params = Dictionary<String,String>()
        do{
            if let projectList: ProjectList = try await RequestController.shared.requestAuthorizedJson(url: requestUrl, withParams: params) {
                //print(projectList.projects)
                await MainActor.run{
                    syncResult.projectsLoaded = projectList.projects.count
                    for project in projectList.projects{
                        
                        syncResult.locationsLoaded += project.locations.count
                        for location in project.locations{
                            syncResult.defectsLoaded += location.defects.count
                        }
                    }
                }
                try await self.loadProjectImages(data: projectList, syncResult: syncResult)
                print("saving project list")
                Store.shared.setProjectList(data: projectList)
            }
        }
        catch {
            await MainActor.run{
                syncResult.downloadErrors += 1
            }
            print("error loading projects")
        }
    }
    
    func clearProjects(){
            Store.shared.setProjectList(data: ProjectList())
            self.clearProjectImages()
    }
    
    func loadProjectImages(data: ProjectList, syncResult: SyncResult) async throws{
        //print("start loading images")
        await withTaskGroup(of: Void.self){ taskGroup in
            for project in data.projects{
                for location in project.locations{
                    if location.plan != nil {
                        taskGroup.addTask{
                            do{
                                try await ImageController.shared.loadProjectImage(image: location.plan!, syncResult: syncResult)
                            }
                            catch{
                                await MainActor.run{
                                    syncResult.downloadErrors += 1
                                }
                            }
                        }
                    }
                    for defect in location.defects{
                        for image in defect.images{
                            taskGroup.addTask{
                                do{
                                    try await ImageController.shared.loadProjectImage(image: image, syncResult: syncResult)
                                }
                                catch{
                                    await MainActor.run{
                                        syncResult.downloadErrors += 1
                                    }
                                }
                            }
                        }
                        for comment in defect.comments{
                            for image in comment.images{
                                taskGroup.addTask{
                                    do{
                                        try await ImageController.shared.loadProjectImage(image: image, syncResult: syncResult)
                                    }
                                    catch{
                                        await MainActor.run{
                                            syncResult.downloadErrors += 1
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
    
    func clearProjectImages(){
        DocumentStore.shared.clearFiles()
    }
    
    func countNewElements() -> Int {
        var count = 0
        for project in Store.shared.projectList.projects{
            for location in project.locations{
                for defect in location.defects{
                    if defect.isNew{
                        print("found new defect \(defect.id)")
                        count += 1
                    }
                    for image in defect.images{
                        if image.isNew{
                            print("found new defect image \(image.id)")
                            count += 1
                        }
                    }
                    for comment in defect.comments{
                        if comment .isNew{
                            print("found new comment \(comment.id)")
                            count += 1
                        }
                        for image in comment.images{
                            if image.isNew{
                                print("found new comment image \(image.id)")
                                count += 1
                            }
                        }
                    }
                }
            }
        }
        return count
    }
    
    func uploadNewItems(syncResult: SyncResult) async{
        let projects = Store.shared.projectList
        await withTaskGroup(of: Void.self){ taskGroup in
            for project in projects.projects{
                for location in project.locations{
                    for defect in location.defects{
                        if (defect.isNew){
                            taskGroup.addTask{
                                do{
                                    try await DefectController.shared.uploadDefect(defect: defect, locationId: location.id, syncResult: syncResult)
                                    await MainActor.run{
                                        syncResult.newElementsCount -= 1
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
                            var count = 0
                            for image in defect.images{
                                if (image.isNew){
                                    count += 1
                                    let nextCount = count
                                    taskGroup.addTask{
                                        do{
                                            try await ImageController.shared.uploadDefectImage(image: image, defectId: defect.id, count: nextCount)
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
                            }
                            for comment in defect.comments{
                                if (comment.isNew){
                                    taskGroup.addTask{
                                        do{
                                            try await DefectController.shared.uploadComment(comment: comment, defectId: defect.id, syncResult: syncResult)
                                            await MainActor.run{
                                                syncResult.newElementsCount -= 1
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
                                    var count = 0
                                    for image in comment.images{
                                        if (image.isNew){
                                            count += 1
                                            let nextCount = count
                                            taskGroup.addTask{
                                                do{
                                                    try await ImageController.shared.uploadCommentImage(image: image, commentId: comment.id, count: nextCount)
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
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        Store.shared.saveProjectList()
    }
    
    func upload(syncResult: SyncResult){
        Task{
            await uploadNewItems(syncResult: syncResult)
        }
    }
    
    func download(syncResult: SyncResult){
        Task{
            await loadProjects(syncResult: syncResult)
            await MainActor.run{
                syncResult.downloadProgress = 1.0
            }
        }
    }
    
}
