//
//  UserData.swift
//  test.ios
//
//  Created by Michael Rönnau on 01.04.20.
//  Copyright © 2020 Michael Rönnau. All rights reserved.
//

import Foundation

class UserData: Codable, Hashable, ObservableObject{
    
    static func == (lhs: UserData, rhs: UserData) -> Bool {
        return lhs.id==rhs.id
    }
    
    var id = 0
    var name = ""
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
 
}

