//
//  ProjectController.swift
//  defecttracker
//
//  Created by Michael Rönnau on 15.04.20.
//  Copyright © 2020 Michael Rönnau. All rights reserved.
//

import Foundation
import Then
import SwiftUI

class ProjectController {
    
    public static var shared = ProjectController()
    
    func loadProjects() -> Promise<SyncResult>{
        return Promise { resolve, reject in
            let requestUrl = Store.shared.serverURL+"/api/project/getProjects"
            let params = Dictionary<String,String>()
            RequestController.shared.requestAuthorizedJson(url: requestUrl, withParams: params).then {
                (projectList : ProjectList) in
                //print(projectList)
                self.loadProjectImages(data: projectList).then { result in
                    result.projectsLoaded = projectList.projects.count
                    //print("saving project list")
                    Store.shared.setProjectList(data: projectList)
                    resolve(result)
                }
            }.onError{
                (e) in
                print(e)
                reject(e)
            }
            
        }
        
    }
    
    func clearProjects(){
            Store.shared.setProjectList(data: ProjectList())
            self.clearProjectImages()
    }
    
    func loadProjectImages(data: ProjectList) -> Promise<SyncResult>{
        return Promise { resolve,reject in
            //print("start loading images")
            var promises: [Promise<Bool>] = Array()
            for project in data.projects{
                for location in project.locations{
                    if location.plan != nil {
                        promises.append(ImageController.shared.loadProjectImage(image: location.plan!))
                    }
                    for defect in location.defects{
                        for image in defect.images{
                            promises.append(ImageController.shared.loadProjectImage(image: image))
                        }
                        for comment in defect.comments{
                            for image in comment.images{
                                promises.append(ImageController.shared.loadProjectImage(image: image))
                            }
                        }
                    }
                }
            }
            Promises.whenAll(promises).then { array in
                let result = SyncResult()
                for i in 0..<array.count {
                    if array[i]{
                        result.imagesDownloaded += 1
                    }
                }
                resolve(result)
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
    
    func uploadNewItems() -> Promise<SyncResult>{
        return Promise { resolve, reject in
            let projects = Store.shared.projectList
            var promises: [Promise<SyncResult>] = Array()
            for project in projects.projects{
                for location in project.locations{
                    for defect in location.defects{
                        if (defect.isNew){
                            promises.append(DefectController.shared.uploadDefect(defect: defect, locationId: location.id))
                        }
                        else{
                            for comment in defect.comments{
                                if (comment.isNew){
                                    promises.append(DefectController.shared.uploadComment(comment: comment, defectId: defect.id))
                                }
                            }
                        }
                    }
                }
            }
            Promises.whenAll(promises).then { (array : Array<SyncResult>) in
                //print("all uploaded")
                let result = SyncResult();
                result.addAll(results: array)
                resolve(result)
            }
        }
        
    }
    
    func synchronize() -> Promise<SyncResult>{
        return Promise { resolve, reject in
            ProjectController.shared.uploadNewItems().then { result in
                ProjectController.shared.loadProjects().then { loadResult in
                    result.add(result: loadResult)
                    resolve(result)
                }
            }.onError{
                (e) in
                reject(e)
            }
        }
        
    }
    
}
