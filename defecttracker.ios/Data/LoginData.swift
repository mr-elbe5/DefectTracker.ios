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
    var expiration : Date? = nil
    
    func isLoggedIn() -> Bool{
        return id != 0 && !name.isEmpty && !token.isEmpty
    }
    
    func dump(){
        print("id="+String(id))
        print("name="+name)
        print("login="+login)
        print("token expiration=" + getTokenExpirationString())
    }
    
    func getTokenExpirationString() -> String {
        if let expiration = expiration {
            return Statics.getDateTimeString(date: expiration)
        }
        return NSLocalizedString("notLoggedIn", comment: "not logged in")
    }
    
    func isLoginValid() -> Bool{
        if let expiration = expiration {
            return expiration.compare(Date()) == .orderedDescending
        }
        return false
    }

}

enum LoginDuration: Identifiable, Hashable, CaseIterable{
    
    case today
    case oneHour
    case oneDay
    case oneWeek
    case oneMonth
    case oneYear
    
    var name: String {
        switch (self){
        case .today : return NSLocalizedString("forToday",comment: "until midnight")
        case .oneHour : return NSLocalizedString("oneHour",comment: "one Hour")
        case .oneDay : return NSLocalizedString("oneDay",comment: "one Day")
        case .oneWeek : return NSLocalizedString("oneWeek",comment: "one Week")
        case .oneMonth: return NSLocalizedString("oneMonth",comment: "one Month")
        case .oneYear: return NSLocalizedString("oneYear",comment: "one Year")
        }
    }
    
    var value: String {
        switch (self){
        case .today: return "today"
        case .oneHour : return "hour"
        case .oneDay : return "day"
        case .oneWeek : return "week"
        case .oneMonth: return "month"
        case .oneYear: return "year"
        }
    }
    
    var id : LoginDuration {self}
}
