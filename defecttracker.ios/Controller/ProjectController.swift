//
//  ProjectController.swift
//  defecttracker
//
//  Created by Michael Rönnau on 15.04.20.
//  Copyright © 2020 Michael Rönnau. All rights reserved.
//

import Foundation
import SwiftUI

protocol ProjectControllerDelegate{
    
    
    
}

class ProjectController {
    
    public static var shared = ProjectController()
    
    var delegate : ProjectControllerDelegate? = nil
    
    //todo
    func loadProjects(callback: @escaping (ProjectList) -> Void){
        let requestUrl = Store.shared.serverURL+"/api/project/getProjects"
        let params = Dictionary<String,String>()
        RequestController.shared.requestAuthorizedJson(url: requestUrl, withParams: params) { (projectList: ProjectList?, error) in
            if let projectList = projectList{
            //print(projectList)
                self.loadProjectImages(data: projectList) { result in
                //result.projectsLoaded = projectList.projects.count
                //print("saving project list")
                Store.shared.setProjectList(data: projectList)
                //result(result)
            }
        }
        }
        
    }
    
    func clearProjects(){
            Store.shared.setProjectList(data: ProjectList())
            self.clearProjectImages()
    }
    
    //todo
    func loadProjectImages(data: ProjectList, callback: @escaping (ProjectList) -> Void){
        //print("start loading images")
        for project in data.projects{
            for location in project.locations{
                if location.plan != nil {
                    ImageController.shared.loadProjectImage(image: location.plan!){ success in
                        
                    }
                }
                for defect in location.defects{
                    for image in defect.images{
                        ImageController.shared.loadProjectImage(image: image){ success in
                            
                        }
                    }
                    for comment in defect.comments{
                        for image in comment.images{
                            ImageController.shared.loadProjectImage(image: image){ success in
                                
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
    
    //todo
    func uploadNewItems(callback: @escaping (Bool) -> Void){
        let projects = Store.shared.projectList
        for project in projects.projects{
            for location in project.locations{
                for defect in location.defects{
                    if (defect.isNew){
                        DefectController.shared.uploadDefect(defect: defect, locationId: location.id){ success in
                            
                        }
                    }
                    else{
                        for comment in defect.comments{
                            if (comment.isNew){
                                DefectController.shared.uploadComment(comment: comment, defectId: defect.id){ success in
                                    
                                }
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    //todo
    func synchronize(){
        ProjectController.shared.uploadNewItems() { result in
            ProjectController.shared.loadProjects() { loadResult in
                //result.add(result: loadResult)
                
            }
        }
        
    }
    
}
