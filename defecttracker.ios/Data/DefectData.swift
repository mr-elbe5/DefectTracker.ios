//
//  DefectData.swift
//  defecttracker
//
//  Created by Michael Rönnau on 15.04.20.
//  Copyright © 2020 Michael Rönnau. All rights reserved.
//

import Foundation
import SwiftUI

class DefectData : Identifiable, Codable, ObservableObject{
    
    enum CodingKeys: String, CodingKey {
        case id
        case displayId
        case description
        case creatorId
        case creatorName
        case creationDate
        case assignedId
        case assignedName
        case lot
        case dueDate
        case planId
        case positionX
        case positionY
        case positionComment
        case state
        case images
        case comments
    }
    
    @Published var id = 0
    @Published var displayId = 0
    @Published var description = ""
    @Published var creator = UserData()
    @Published var creationDate = Date()
    @Published var assigned = UserData()
    @Published var lot = ""
    @Published var dueDate = Date()
    @Published var planId = 0
    @Published var position : CGSize = .zero
    @Published var positionComment = ""
    @Published var state = Statics.defectStates[0]
    
    @Published var images = Array<ImageData>()
    
    @Published var comments = Array<DefectCommentData>()
    
    init(){
    }
    
    init(id : Int, location: LocationData){
        self.id=id
        self.displayId=id
        self.creator=UserData()
        self.creator.id=Store.shared.loginData.id
        self.creator.name=Store.shared.loginData.name
        self.planId = location.plan != nil ? location.plan!.id : 0
    }
    
    var isNew : Bool{
        return id >= Statics.minNewId
    }
    
    var hasValidPosition : Bool{
        position != .zero
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        displayId = try values.decodeIfPresent(Int.self, forKey: .displayId) ?? id
        description = try values.decodeIfPresent(String.self, forKey: .description) ?? ""
        creator=UserData()
        creator.id = try values.decodeIfPresent(Int.self, forKey: .creatorId) ?? 1
        creator.name = try values.decodeIfPresent(String.self, forKey: .creatorName) ?? "n/n"
        assigned = UserData()
        assigned.id = try values.decodeIfPresent(Int.self, forKey: .assignedId) ?? 1
        assigned.name = try values.decodeIfPresent(String.self, forKey: .assignedName) ?? "n/n"
        lot = try values.decodeIfPresent(String.self, forKey: .lot) ?? ""
        dueDate = try values.decodeIfPresent(Date.self, forKey: .dueDate) ?? Date.now
        planId = try values.decodeIfPresent(Int.self, forKey: .planId) ?? 0
        position.width = try CGFloat(values.decodeIfPresent(Int.self, forKey: .positionX) ?? 0)
        position.height = try CGFloat(values.decodeIfPresent(Int.self, forKey: .positionY) ?? 0)
        positionComment = try values.decodeIfPresent(String.self, forKey: .positionComment) ?? ""
        state = try values.decodeIfPresent(String.self, forKey: .state) ?? "OPEN"
        images = try values.decodeIfPresent(Array<ImageData>.self, forKey: .images) ?? Array<ImageData>()
        comments = try values.decodeIfPresent(Array<DefectCommentData>.self, forKey: .comments) ?? Array<DefectCommentData>()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(displayId, forKey: .displayId)
        try container.encode(description, forKey: .description)
        try container.encode(creator.id, forKey: .creatorId)
        try container.encode(creator.name, forKey: .creatorName)
        try container.encode(assigned.id, forKey: .assignedId)
        try container.encode(assigned.name, forKey: .assignedName)
        try container.encode(lot, forKey: .lot)
        try container.encode(dueDate, forKey: .dueDate)
        try container.encode(planId, forKey: .planId)
        try container.encode(Int(position.width), forKey: .positionX)
        try container.encode(Int(position.height), forKey: .positionY)
        try container.encode(positionComment, forKey: .positionComment)
        try container.encode(state, forKey: .state)
        try container.encode(images, forKey: .images)
        try container.encode(comments, forKey: .comments)
    }
    
    func getUploadParams() -> Dictionary<String,String>{
        var dict = Dictionary<String,String>()
        dict["id"]=String(id)
        dict["displayId"]=String(displayId)
        dict["creatorId"]=String(creator.id)
        dict["creatorName"]=creator.name
        dict["description"]=String(description)
        dict["assignedId"]=String(assigned.id)
        dict["assignedName"]=assigned.name
        dict["lot"]=lot
        dict["planId"]=String(planId)
        dict["positionX"]=String(Int(position.width))
        dict["positionY"]=String(Int(position.height))
        dict["positionComment"]=positionComment
        dict["state"]=state
        return dict
    }
    
}
