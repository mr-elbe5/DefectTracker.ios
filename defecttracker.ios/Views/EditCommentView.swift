//
//  EditCommentView.swift
//  defecttracker
//
//  Created by Michael Rönnau on 23.04.20.
//  Copyright © 2020 Michael Rönnau. All rights reserved.
//

import Foundation
import SwiftUI

struct EditCommentView: View {
    
    @ObservedObject var comment : DefectCommentData
    @ObservedObject var defect : DefectData
    
    @State var showImagePicker: Bool = false
    @State var sourceType : UIImagePickerController.SourceType = .camera
    
    @State var showAlert1 = false;
    
    @Environment(\.presentationMode) var presentation
    
    private enum alertKey{
        case incomplete, error
    }
    
    init(defect: DefectData, comment: DefectCommentData){
        comment.state = defect.state
        self.comment = comment
        self.defect = defect
    }
    
    var body: some View {
        ZStack{
            Form{
                VStack(alignment: .leading, spacing: 2){
                    Text("comment".localize()+" *")
                    MultilineTextField(placeholder: "enterComment".localize(), text: self.$comment.comment).withMultilineStyle()
                }
                Picker(selection: self.$comment.state, label: Text("state".localize()+" *")){
                    ForEach((0...3), id: \.self){
                        Text(NSLocalizedString(Statics.defectStates[$0],comment: "")).tag(Statics.defectStates[$0])
                    }
                }
                VStack(alignment: .leading, spacing: 2){
                    Text("images").font(.headline)
                    FormImageBlock(images: comment.images)
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
                }.padding(.top).alert(isPresented: $showAlert1){
                    return Alert(title: Text("incomplete"), message:Text("fillAllFields"), dismissButton: .default(Text("ok")))
                }
                HStack(){
                    Spacer()
                    Image(systemName: "keyboard.chevron.compact.down").onTapGesture {
                        self.dismissKeyboard()
                    }
                }
            }
            if showImagePicker{
                ImagePicker(isShown: $showImagePicker, sourceType: self.$sourceType, imageList: self.$comment.images)
            }
        }.navigationBarTitle(Text("comment \(String(comment.id))"), displayMode: .inline)
    }
    
    func isComplete() -> Bool{
        return !self.comment.comment.isEmpty
    }
    
    func save() -> Void{
        if (self.isComplete()){
            defect.comments.append(comment)
            defect.state = comment.state
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

struct EditCommentView_Previews: PreviewProvider {
    static var comment = DefectCommentData()
    static var defect = DefectData()
    static var previews: some View {
        EditCommentView(defect: defect, comment: comment)
    }
}
