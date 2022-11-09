//
//  LocationData.swift
//  defecttracker
//
//  Created by Michael Rönnau on 15.04.20.
//  Copyright © 2020 Michael Rönnau. All rights reserved.
//

import Foundation

class LocationData : Identifiable, Codable, ObservableObject{
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case plan
        case defects
    }
    
    @Published var id = 0
    @Published var name = ""
    @Published var description = ""
    
    @Published var plan : ImageData? = nil
    
    @Published var defects = Array<DefectData>()
    
    var project: ProjectData? = nil
    
    init(){
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        description = try values.decode(String.self, forKey: .description)
        plan = try values.decodeIfPresent(ImageData.self, forKey: .plan)
        defects = try values.decode(Array<DefectData>.self, forKey: .defects)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(plan, forKey: .plan)
        try container.encode(defects, forKey: .defects)
    }
    
}
