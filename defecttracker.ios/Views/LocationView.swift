//
//  LocationView.swift
//  defecttracker
//
//  Created by Michael Rönnau on 15.04.20.
//  Copyright © 2020 Michael Rönnau. All rights reserved.
//

import Foundation
import SwiftUI

struct LocationView: View {
    
    @ObservedObject var location : LocationData
    var uiImage : UIImage?
    @State var createDefect : Int? = nil
    
    init(location : LocationData){
        self.location = location
        self.uiImage = location.plan == nil ? nil : ImageController.shared.getImage(image: location.plan!)
    }
    
    var body: some View {
        GeometryReader{ geo in
            ScrollView{
                VStack(alignment: .leading){
                    if !self.location.description.isEmpty{
                        Text("description".localize()).font(.headline)
                        Text(self.location.description)
                    }
                    if self.uiImage != nil {
                        Text("plan").font(.headline)
                        NavigationLink(destination: PlanView(uiImage: self.uiImage!, defects: self.location.defects)){
                            StaticPlanView(uiImage: self.uiImage!, defects: self.location.defects).frame(width: geo.size.width, height: geo.size.width * self.uiImage!.size.height / self.uiImage!.size.width)
                        }
                    }
                    NavigationLink(destination: EditDefectView(location: self.location, defect: DefectData(id: Store.shared.getNextId(), location: self.location)), tag: 1, selection: self.$createDefect){
                        Text("defects").foregroundColor(Color.primary).font(.headline)
                    }
                    Button(action: {
                        self.createDefect=1
                    }, label: {HStack{
                        Text("newDefect").foregroundColor(Color.accentColor)
                        Spacer()
                        Image(systemName: "chevron.right").foregroundColor(Color.accentColor)
                        }
                    }).padding(.top)
                    ForEach(self.location.defects){
                        (defect : DefectData) in
                        NavigationLink(destination: DefectView(defect: defect, location: self.location)){
                            NavigationRow(text: "ID \(defect.displayId): \(defect.description)")
                        }
                    }
                    Spacer()
                }
            }
        }.fullSize().navigationBarTitle(Text(location.name), displayMode: .inline)
    }
}


struct LocationView_Previews: PreviewProvider {
    static var previews: some View {
        LocationView(location: LocationData())
    }
}
