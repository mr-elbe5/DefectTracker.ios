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
        case phase
        case name
        case description
        case locations
        case users
    }
    
    @Published var id = 0
    @Published var phase = ""
    @Published var name = ""
    @Published var description = ""
    
    @Published var locations = Array<LocationData>()
    
    @Published var users = Array<UserData>()
    
    init(){
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        phase = try values.decode(String.self, forKey: .phase)
        name = try values.decode(String.self, forKey: .name)
        description = try values.decode(String.self, forKey: .description)
        locations = try values.decode(Array<LocationData>.self, forKey: .locations)
        for location in locations{
            location.project=self
        }
        users = try values.decode(Array<UserData>.self, forKey: .users)
        //print("project name= \(name)")
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(phase, forKey: .phase)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(locations, forKey: .locations)
        try container.encode(users, forKey: .users)
    }
    

}
