//
//  String.swift
//  defecttracker
//
//  Created by Michael Rönnau on 18.05.20.
//  Copyright © 2020 Michael Rönnau. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func localize() -> String{
        return NSLocalizedString(self,comment: "")
    }
    
    func localize(i: Int) -> String{
        return String(format: NSLocalizedString(self,comment: ""), String(i))
    }
    
    func localize(s: String) -> String{
        return String(format: NSLocalizedString(self,comment: ""), s)
    }
    
    func localize(b: Bool) -> String{
        return String(format: NSLocalizedString(self,comment: ""), String(b))
    }

}

extension String: Error {
    
}
