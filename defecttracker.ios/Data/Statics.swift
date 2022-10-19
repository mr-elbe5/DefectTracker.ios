//
//  Statics.swift
//  defecttracker
//
//  Created by Michael Rönnau on 14.04.20.
//  Copyright © 2020 Michael Rönnau. All rights reserved.
//

import Foundation
import SwiftUI

struct Statics {
    
    static var defectStates = ["OPEN", "DISPUTED", "REJECTED", "DONE"]
    
    static var maxImageEdge : CGFloat = 800
    
    static var minNewId = 1000000
    
    static func localizedState(index: Int) -> String{
        if index >= 0 && index < 4 {
            return NSLocalizedString(defectStates[index],comment: "")
        }
        return ""
    }
    
    static func stateIndex(of: String) -> Int{
        for i in (0...3){
            if of == defectStates[i]{
                return i
            }
        }
        return -1
    }
    
    static func getDateString(date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: date)
    }
    
    static func getDateTimeString(date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        return dateFormatter.string(from: date)
    }
    
}
