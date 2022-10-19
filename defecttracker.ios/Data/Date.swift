//
//  Date.swift
//  defecttracker
//
//  Created by Michael Rönnau on 17.05.20.
//  Copyright © 2020 Michael Rönnau. All rights reserved.
//

import Foundation

extension Date {
 var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }

    init(milliseconds:Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }
}
