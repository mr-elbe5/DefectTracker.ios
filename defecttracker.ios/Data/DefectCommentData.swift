//
//  DefectCommentData.swift
//  defecttracker
//
//  Created by Michael Rönnau on 15.04.20.
//  Copyright © 2020 Michael Rönnau. All rights reserved.
//

import Foundation

class DefectCommentData : Identifiable, Codable, ObservableObject{
    
    enum CodingKeys: String, CodingKey {
        case id
        case creatorId
        case creatorName
        case creationDate
        case comment
        case state
        case images
    }
    
    @Published var id = 0
    @Published var creator = UserData()
    @Published var creationDate = Date()
    @Published var comment = ""
    @Published var state = Statics.defectStates[0]
    
    @Published var images = Array<ImageData>()
    
    init(){
    }
    
    init(id : Int){
        self.id=id
        self.creator=UserData()
        self.creator.id=Store.shared.loginData.id
        self.creator.name=Store.shared.loginData.name
    }
    
    var isNew : Bool{
        return id >= Statics.minNewId
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        creator.id = try values.decodeIfPresent(Int.self, forKey: .creatorId) ?? 1
        creator.name = try values.decodeIfPresent(String.self, forKey: .creatorName) ?? "n/n"
        creationDate = try values.decodeIfPresent(Date.self, forKey: .creationDate) ?? Date.now
        comment = try values.decodeIfPresent(String.self, forKey: .comment) ?? ""
        state = try values.decodeIfPresent(String.self, forKey: .state) ?? "OPEN"
        images = try values.decodeIfPresent(Array<ImageData>.self, forKey: .images) ?? Array<ImageData>()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(creator.id, forKey: .creatorId)
        try container.encode(creator.name, forKey: .creatorName)
        try container.encode(creationDate, forKey: .creationDate)
        try container.encode(comment, forKey: .comment)
        try container.encode(state, forKey: .state)
        try container.encode(images, forKey: .images)
    }
    
    func getUploadParams() -> Dictionary<String,String>{
        var dict = Dictionary<String,String>()
        dict["id"]=String(id)
        dict["creatorId"]=String(creator.id)
        dict["creatorName"]=creator.name
        dict["comment"]=String(comment)
        dict["state"]=state
        return dict
    }
    
}
