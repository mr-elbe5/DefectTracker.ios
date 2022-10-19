//
//  PropertyLine.swift
//  defecttracker
//
//  Created by Michael Rönnau on 17.04.20.
//  Copyright © 2020 Michael Rönnau. All rights reserved.
//

import Foundation
import SwiftUI

struct PropertyLine: View{
    
    var label : Text
    var text: Text
    
    init(label: String, text: String){
        self.label=Text(label)
        self.text=Text(text)
    }
    
    init(key: String, text: String){
        self.label=Text(NSLocalizedString(key,comment: ""))
        self.text=Text(text)
    }
    
    init(key: String, date: Date){
        self.label=Text(NSLocalizedString(key,comment: ""))
        self.text=Text(Statics.getDateString(date: date))
    }
    
    var body: some View {
        HStack(spacing: 5){
            self.label.frame(maxWidth: .infinity, alignment: .leading)
            self.text.frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct PropertyLine_Previews: PreviewProvider {
    static var previews: some View {
        PropertyLine(label: "test", text:"test")
    }
}
