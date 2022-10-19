//
//  AppInfo.swift
//  defecttracker
//
//  Created by Michael Rönnau on 18.05.20.
//  Copyright © 2020 Michael Rönnau. All rights reserved.
//

import Foundation
import SwiftUI

struct AppInfo: View{
    
    @State var tokenExpiration : String = ""
    
    private enum alertKey{
        case error
    }
    @State var showAlert = false;
    
    var body: some View{
        ScrollView{
            VStack(alignment: .leading){
                Group{
                    Text("infoHeader1").font(.headline)
                    Spacer(minLength: 10)
                    Text("infoText1")
                }
                Group{
                    Spacer(minLength: 25)
                    Text("infoHeader2").font(.headline)
                    Spacer(minLength: 10)
                    Text("infoText2")
                }
                Group{
                    Spacer(minLength: 25)
                    Text("infoHeader3").font(.headline)
                    Spacer(minLength: 10)
                    Text("infoText3")
                }
                Spacer()
            }.fullSize()
        }.navigationBarTitle("info" ,displayMode: .inline)
    }
    
    
}

struct AppInfo_Previews: PreviewProvider {
    static var previews: some View {
        AppInfo()
    }
}
