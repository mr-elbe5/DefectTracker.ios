//
//  ProjectData.swift
//  defecttracker
//
//  Created by Michael Rönnau on 15.04.20.
//  Copyright © 2020 Michael Rönnau. All rights reserved.
//

import Foundation
import SwiftUI

class ProjectData : Identifiable, Codable, ObservableObject{
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case locations
        case users
    }
    
    @Published var id = 0
    @Published var name = ""
    @Published var description = ""
    
    @Published var locations = Array<LocationData>()
    
    @Published var users = Array<UserData>()
    
    init(){
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        name = try values.decodeIfPresent(String.self, forKey: .name) ?? "project"
        description = try values.decodeIfPresent(String.self, forKey: .description) ?? ""
        locations = try values.decodeIfPresent(Array<LocationData>.self, forKey: .locations) ?? Array<LocationData>()
        for location in locations{
            location.project=self
        }
        users = try values.decodeIfPresent(Array<UserData>.self, forKey: .users) ?? Array<UserData>()
        //print("project name= \(name)")
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(locations, forKey: .locations)
        try container.encode(users, forKey: .users)
    }
    

}
