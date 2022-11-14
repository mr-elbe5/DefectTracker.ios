//
//  IdResponse.swift
//  defecttracker
//
//  Created by Michael Rönnau on 17.05.20.
//  Copyright © 2020 Michael Rönnau. All rights reserved.
//

import Foundation

class IdResponse : Codable, ObservableObject{
    
    enum CodingKeys: String, CodingKey {
        case id
    }
    
    @Published var id = 0
    
    init(){
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id) ?? 0
        //print("id response = \(id)")
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
    }
    
}
