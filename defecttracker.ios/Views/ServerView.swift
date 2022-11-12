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
    
    @State var showClearAlert = false
    
    @State var newElementsCount = 0
    
    @StateObject var syncResult : SyncResult = SyncResult()
    
    let projectController = ProjectController()
    
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
                            projectController.synchronize(syncResult: syncResult)
                        }) {
                            Text("synchronize")
                        }
                        VStack(alignment: .leading){
                            VStack(alignment: .leading){
                                Text("uploaded".localize())
                                    .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                                Text("syncedDefects".localize(i: syncResult.defectsUploaded))
                                Text("syncedComments".localize(i:syncResult.commentsUploaded))
                                Text("syncedImages".localize(i: syncResult.imagesUploaded))
                                Text("syncErrors".localize(i: syncResult.uploadErrors))
                            }
                            VStack(alignment: .leading){
                                Text("downloaded".localize())
                                    .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                                Text("syncedProjects".localize(i: syncResult.projectsLoaded))
                                Text("syncedLocations".localize(i: syncResult.locationsLoaded))
                                Text("syncedDefects".localize(i: syncResult.defectsLoaded))
                                Text("syncedImages".localize(i: syncResult.imagesLoaded))
                                Text("syncErrors".localize(i: syncResult.downloadErrors))
                            }
                            Slider(value: $syncResult.progress,in: 0...100)
                        }
                    }
                    
                }
                Section{
                    VStack{
                        Button(action: {
                            projectController.clearProjects()
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
            self.newElementsCount = projectController.countNewElements()
        }
    }
    
}

struct ServerView_Previews: PreviewProvider {
    static var previews: some View {
        ServerView()
    }
}
