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
    
    let insets = EdgeInsets(top: 2, leading: 10, bottom: 2, trailing: 0)
    
    init(text: String){
        self.text=text.localize()
    }
    
    var body: some View{
        HStack{
            Text(text).foregroundColor(Color.primary).padding(insets)
            Spacer()
            Image(systemName: "chevron.right").foregroundColor(Color.accentColor).padding(.trailing)
        }.background(Color(red: 0.95, green: 0.95, blue: 0.95)).cornerRadius(10).foregroundColor(Color.accentColor)
    }
}

struct NavigationRow_Previews: PreviewProvider {
    static var previews: some View {
        NavigationRow(text: "Test")
    }
}
