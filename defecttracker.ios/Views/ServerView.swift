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
    @State var showWaitAlert = false
    @State var showSuccessAlert = false
    @State var showErrorAlert = false
    @State var showClearAlert = false
    @State var newElementsCount = 0
    
    @State var syncResult : SyncResult = SyncResult()
    
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
                            Text(store.loginData.isLoggedIn() ? "loggedin" : "notLoggedIn")
                                .foregroundColor(store.loginData.isLoggedIn() ? Color.black : Color.red)
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
                            syncResult.reset()
                            ProjectController.shared.delegate = self
                            self.showWaitAlert = true
                            ProjectController.shared.synchronize(syncResult: syncResult)
                            
                        }) {
                            Text("synchronize")
                        }.alert(isPresented: $showWaitAlert){
                            return Alert(title: Text("pleaseWait".localize()), message:Text("syncronizing".localize()), dismissButton: .cancel(Text("cancel")))
                        }.alert(isPresented: $showSuccessAlert){
                            return Alert(title: Text("success".localize()), message:Text("syncronizationFinished".localize()), dismissButton: .default(Text("ok")))
                        }.alert(isPresented: $showErrorAlert){
                            return Alert(title: Text("error"), message:Text("syncronizationFailed"), dismissButton: .default(Text("ok")))
                        }
                        VStack(alignment: .leading){
                            VStack(alignment: .leading){
                                Text("uploaded".localize()).padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                                Text("syncedDefects".localize(i: syncResult.defectsUploaded))
                                Text("syncedComments".localize(i:syncResult.commentsUploaded))
                                Text("syncedImages".localize(i: syncResult.imagesUploaded))
                                Text("syncErrors".localize(i: syncResult.uploadErrors))
                            }
                            VStack(alignment: .leading){
                                Text("downloaded".localize()).padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                                Text("syncedProjects".localize(i: syncResult.projectsLoaded))
                                Text("syncedLocations".localize(i: syncResult.locationsLoaded))
                                Text("syncedDefects".localize(i: syncResult.defectsLoaded))
                                Text("syncedImages".localize(i: syncResult.imagesLoaded))
                                Text("syncErrors".localize(i: syncResult.downloadErrors))
                            }
                        }
                    }
                }
                Section{
                    VStack{
                        Button(action: {
                            ProjectController.shared.clearProjects()
                            self.syncResult.reset()
                            self.showClearAlert = true
                        })
                        {
                            Text("clearProjects")
                        }.alert(isPresented: $showClearAlert){
                            return Alert(title: Text("success"), message:Text("projectsCleared"), dismissButton: .default(Text("ok")))
                            
                        }
                    }
                }
            }
        }.navigationBarTitle("cloud" ,displayMode: .inline).onAppear{
            self.newElementsCount = ProjectController.shared.countNewElements()
        }
    }
    
}

extension ServerView: ProjectControllerDelegate{
    
    func syncReady() {
        showWaitAlert = false
        if syncResult.hasErrors(){
            showErrorAlert = true
        }
        else{
            showSuccessAlert = true
        }
        self.newElementsCount=0
    }
    
}

struct ServerView_Previews: PreviewProvider {
    static var previews: some View {
        ServerView()
    }
}
