//
//  LoginData.swift
//  test.ios
//
//  Created by Michael Rönnau on 01.04.20.
//  Copyright © 2020 Michael Rönnau. All rights reserved.
//

import Foundation

class LoginData: Codable{
    
    var id = 0
    var login = ""
    var name = ""
    var token = ""
    
    func isLoggedIn() -> Bool{
        return id != 0 && !name.isEmpty && !token.isEmpty
    }
    
    func dump(){
        print("id="+String(id))
        print("name="+name)
        print("login="+login)
    }

}

