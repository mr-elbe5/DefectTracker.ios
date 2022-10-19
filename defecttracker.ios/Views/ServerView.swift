//
//  ServerView.swift
//  defecttracker
//
//  Created by Michael Rönnau on 15.04.20.
//  Copyright © 2020 Michael Rönnau. All rights reserved.
//

import Foundation
import SwiftUI

struct ServerView: View{
    
    @ObservedObject var store = Store.shared
    
    private enum alertKey{
        case error
    }
    @State var showAlert1 = false;
    @State var showAlert2 = false;
    @State var newElementsCount = 0
    @State var syncResult : SyncResult = SyncResult()
    
    @State private var shouldAnimate = false
    
    var body: some View{
        ZStack{
            Form{
                Section{
                    List{
                        VStack(alignment: .leading, spacing: 5){
                            Text("cloudURL")
                            Text(store.serverURL)
                        }
                        VStack(alignment: .leading, spacing: 5){
                            Text("loggedinUntil")
                            Text(store.loginData.getTokenExpirationString()).foregroundColor(store.loginData.isLoginValid() ? Color.black : Color.red)
                        }
                    }
                    NavigationLink(destination: LoginView()){
                        Text("login")
                    }.foregroundColor(Color.accentColor)
                }
                Section{
                    List{
                        Text("newElements \(String(newElementsCount))")
                        Button(action: {
                            self.shouldAnimate=true
                            ProjectController.shared.synchronize().then{
                                (result : SyncResult) in
                                self.shouldAnimate=false
                                self.syncResult = result
                                self.newElementsCount=0
                                self.showAlert1=true
                            }
                        }) {
                            Text("synchronize")
                        }.alert(isPresented: $showAlert1){
                            let text = "synchronized".localize() + "\n" +
                                "syncedDefects".localize(i: self.syncResult.defectsUploaded) +
                                "syncedComments".localize(i: self.syncResult.commentsUploaded) +
                                "syncedImages".localize(i: self.syncResult.imagesUploaded) + "\n" +
                                "syncedProjects".localize(i: self.syncResult.projectsLoaded);
                            return Alert(title: Text("success"), message:Text(text), dismissButton: .default(Text("ok")))
                            
                        }
                    }
                }
                Section{
                    VStack{
                        Button(action: {
                            ProjectController.shared.clearProjects()
                            self.syncResult.projectsLoaded = 0
                            self.showAlert2=true
                        })
                        {
                            Text("clearProjects")
                        }.alert(isPresented: $showAlert2){
                            return Alert(title: Text("success"), message:Text("projectsCleared"), dismissButton: .default(Text("ok")))
                            
                        }
                    }
                }
            }
            ActivityIndicator(shouldAnimate: self.$shouldAnimate)
        }.navigationBarTitle("cloud" ,displayMode: .inline).onAppear{
            self.newElementsCount = ProjectController.shared.countNewElements()
        }
    }
    
}

struct ServerView_Previews: PreviewProvider {
    static var previews: some View {
        ServerView()
    }
}
