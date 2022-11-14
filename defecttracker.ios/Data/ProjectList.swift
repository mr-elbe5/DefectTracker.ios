//
//  ProjectList.swift
//  defecttracker
//
//  Created by Michael Rönnau on 15.04.20.
//  Copyright © 2020 Michael Rönnau. All rights reserved.
//

import Foundation

class ProjectList : Codable, ObservableObject{
    
    enum CodingKeys: String, CodingKey {
        case projects
    }
    
    @Published var projects = Array<ProjectData>()
    
    init(){
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        projects = try values.decodeIfPresent(Array<ProjectData>.self, forKey: .projects) ?? Array<ProjectData>()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(projects, forKey: .projects)
    }
    
}
