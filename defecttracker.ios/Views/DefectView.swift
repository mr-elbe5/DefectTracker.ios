//
//  DefectView.swift
//  defecttracker
//
//  Created by Michael Rönnau on 15.04.20.
//  Copyright © 2020 Michael Rönnau. All rights reserved.
//

import Foundation
import SwiftUI

struct DefectView: View {
    
    @ObservedObject var defect : DefectData
    @ObservedObject var location : LocationData
    var uiImage : UIImage?
    
    @State var createComment : Int? = nil
    
    init(defect : DefectData, location: LocationData){
        self.defect = defect
        self.location = location
        self.uiImage = location.plan == nil ? nil : ImageController.shared.getImage(image: location.plan!)
    }
    
    var body: some View {
        GeometryReader{ geo in
            ScrollView{
                VStack(alignment: .leading){
                    Group{
                        Text("details").font(.headline)
                        PropertyLine(key: "id", text: String(self.defect.displayId))
                        PropertyLine(key: "description",text: self.defect.description)
                        PropertyLine(key: "creator",text: self.defect.creator.name)
                        PropertyLine(key: "onDate",text: Statics.getDateTimeString(date: defect.creationDate))
                        PropertyLine(key: "assigned", text: self.defect.assigned.name)
                        PropertyLine(key: "lot",text: self.defect.lot)
                        PropertyLine(key: "dueDate",date: self.defect.dueDate)
                        PropertyLine(key: "state", text: self.defect.state.localize())
                        Spacer(minLength: 20)
                    }
                    Group{
                        if self.uiImage != nil {
                            Text("plan").font(.headline)
                            NavigationLink(destination: PlanView(uiImage: self.uiImage!, defects: self.location.defects)){
                                StaticPlanView(uiImage: self.uiImage!, defect: self.defect).frame(width: geo.size.width, height: geo.size.width * self.uiImage!.size.height / self.uiImage!.size.width)
                            }
                        }
                        Text("images").font(.headline)
                        ImageBlock(images: self.defect.images)
                        NavigationLink(destination: EditCommentView(defect: self.defect, comment: DefectCommentData(id: Store.shared.getNextId())), tag: 1, selection: self.$createComment){
                            Text("comments").foregroundColor(Color.primary).font(.headline)
                        }
                        Button(action: {
                            self.createComment=1
                        }, label: {
                            Label("newComment", systemImage: "plus.circle")
                        }).padding(.top)
                    }
                    ForEach(self.defect.comments){ (comment : DefectCommentData) in
                        Text("comment".localize()).bold().padding(.top)
                        Text(self.getCommentBy(comment: comment))
                        Text(comment.comment)
                        if !comment.images.isEmpty{
                            Text("images")
                            ImageBlock(images: comment.images)
                        }
                    }
                }
            }
        }.fullSize()
            .navigationBarTitle(Text("defect \(String(defect.displayId))"), displayMode: .inline)
    }
    
    func getCommentBy(comment: DefectCommentData) -> String{
        return "(" + comment.creator.name + " " + "onDate".localize() + " " + Statics.getDateTimeString(date: comment.creationDate)+")"
    }
}

struct DefectView_Previews: PreviewProvider {
    static var previews: some View {
        DefectView(defect: DefectData(), location: LocationData())
    }
}
