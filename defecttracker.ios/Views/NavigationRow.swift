//
//  NavigationRow.swift
//  defecttracker
//
//  Created by Michael Rönnau on 22.04.20.
//  Copyright © 2020 Michael Rönnau. All rights reserved.
//

import Foundation
import SwiftUI

struct NavigationRow: View{
    
    var text: String;
    
    init(text: String){
        self.text=NSLocalizedString(text,comment: "")
    }
    
    var body: some View{
        HStack{
            Text(text).foregroundColor(Color.primary)
            Spacer()
            Image(systemName: "chevron.right").foregroundColor(Color.accentColor)
        }.foregroundColor(Color.accentColor)
    }
}

struct NavigationRow_Previews: PreviewProvider {
    static var previews: some View {
        NavigationRow(text: "Test")
    }
}
