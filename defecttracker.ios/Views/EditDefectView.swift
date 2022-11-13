//
//  EditDefectView.swift
//  defecttracker
//
//  Created by Michael Rönnau on 23.04.20.
//  Copyright © 2020 Michael Rönnau. All rights reserved.
//

import Foundation
import SwiftUI

struct EditDefectView: View {
    
    @ObservedObject var defect : DefectData
    var location : LocationData
    var uiImage : UIImage?
    var users : Array<UserData>
    
    @State var showImagePicker: Bool = false
    @State var sourceType : UIImagePickerController.SourceType = .camera
    @State var position : CGSize = .zero
    
    private enum alertKey{
        case incomplete, error
    }
    
    @State var showAlert1 = false;
    
    @Environment(\.presentationMode) var presentation
    
    init(location: LocationData, defect: DefectData){
        self.defect = defect
        self.location = location
        self.uiImage = location.plan == nil ? nil :ImageController.shared.getImage(image: location.plan!)
        if let project = self.location.project{
            self.users = project.users
        }
        else{
            self.users = Array<UserData>()
        }
        self.position = defect.position
    }
    
    var body: some View {
        GeometryReader{ geo in
            Form{
                Group{
                    VStack(alignment: .leading, spacing: 2){
                        Text("description".localize()+" *")
                        MultilineTextField(placeholder: "enterDescription".localize(), text: self.$defect.description).withMultilineStyle()
                    }
                    Picker(selection: self.$defect.assigned, label: Text("assigned".localize()+" *")){
                        Text("pleaseSelect")
                        ForEach(self.users, id: \.self.id) { (opt:UserData) in
                            Text(opt.name).tag(opt)
                        }
                    }.pickerStyle(DefaultPickerStyle())
                    VStack(alignment: .leading, spacing: 2){
                        Text("lot")
                        TextField("", text: self.$defect.lot).withTextFieldStyle()
                    }
                    DatePicker(selection: self.$defect.dueDate, displayedComponents: [.date]){
                        Text("dueDate".localize()+" *")
                    }
                    Picker(selection: self.$defect.state, label: Text("state".localize()+" *")){
                        ForEach((0...3), id: \.self){
                            Text(NSLocalizedString(Statics.defectStates[$0],comment: "")).tag(Statics.defectStates[$0])
                        }
                    }
                    if let image = uiImage {
                        Text("positionInPlan").font(.headline)
                        NavigationLink(destination: PositionFinderView(defect: self.defect, uiImage: image)){
                            StaticPlanView(uiImage: image, defect: self.defect)
                                .frame(width: geo.size.width, height: geo.size.width * image.size.height / image.size.width)
                        }
                    }
                }
                VStack(alignment: .leading, spacing: 2){
                    Text("images").font(.headline)
                    FormImageBlock(images: self.defect.images)
                }
                Button("addPhoto") {
                    self.sourceType = .camera
                    self.showImagePicker.toggle()
                }
                Button("addFromGallery") {
                    self.sourceType = .photoLibrary
                    self.showImagePicker.toggle()
                }
                Text("")
                Button(action: {
                    self.save()
                }) {
                    Text("save")
                }.padding(.top)
                    .alert(isPresented: self.$showAlert1){
                        return Alert(title: Text("incomplete"), message:Text("fillAllFields"), dismissButton: .default(Text("ok")))
                }
                HStack(){
                    Spacer()
                    Image(systemName: "keyboard.chevron.compact.down").onTapGesture {
                        self.dismissKeyboard()
                    }
                }
            }
            if self.showImagePicker{
                ImagePicker(isShown: self.$showImagePicker, sourceType: self.$sourceType, imageList: self.$defect.images)
            }
        }.navigationBarTitle(Text("defect \(String(defect.displayId))"), displayMode: .inline)
    }
    
    func isComplete() -> Bool{
        return !self.defect.description.isEmpty && self.defect.assigned.id != 0
    }
    
    func save() -> Void{
        if (self.isComplete()){
            self.location.defects.append(self.defect)
            Store.shared.saveProjectList()
            goBack()
        }
        else{
            self.showAlert1=true
        }
    }
    
    func goBack(){
        self.presentation.wrappedValue.dismiss()
    }
}

struct EditDefectView_Previews: PreviewProvider {
    static var location = LocationData()
    static var defect = DefectData()
    
    static var previews: some View {
        EditDefectView(location: location, defect: defect)
    }
}



