//
//  ImageData.swift
//  test.ios
//
//  Created by Michael Rönnau on 04.04.20.
//  Copyright © 2020 Michael Rönnau. All rights reserved.
//

import Foundation
import SwiftUI

class ImageData : Identifiable, Codable, ObservableObject{
    
    enum CodingKeys: String, CodingKey {
        case id
        case displayName
        case fileName
        case contentType
        case width
        case height
    }
    
    @Published var id = 0
    @Published var displayName = ""
    @Published var fileName = ""
    @Published var contentType = ""
    @Published var width = 0
    @Published var height = 0
    
    init(){
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        displayName = try values.decode(String.self, forKey: .displayName)
        fileName = try values.decode(String.self, forKey: .fileName)
        contentType = try values.decode(String.self, forKey: .contentType)
        width = try values.decode(Int.self, forKey: .width)
        height = try values.decode(Int.self, forKey: .height)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(displayName, forKey: .displayName)
        try container.encode(fileName, forKey: .fileName)
        try container.encode(contentType, forKey: .contentType)
        try container.encode(width, forKey: .width)
        try container.encode(height, forKey: .height)
    }
    
    func getLocalFileName() -> String{
        return String(id) + "_" + fileName
    }
    
    
}
