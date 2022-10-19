//
//  ContentView.swift
//  defecttracker.ios
//
//  Created by Michael Rönnau on 14.04.20.
//  Copyright © 2020 Michael Rönnau. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var store = Store.shared
    
    var body: some View {
        NavigationView {
            ScrollView{
                VStack(alignment: .leading){
                    ForEach(store.projectList.projects){
                        (project : ProjectData) in
                        ProjectRow(project: project)
                    }
                    if (store.projectList.projects.count==0){
                        Text("startInfo")
                    }
                    Spacer()
                }.navigationBarTitle("home", displayMode: .inline)
                    .navigationBarItems(trailing:
                        HStack(spacing: 15){
                            NavigationLink(destination: ServerView()){
                                Image(systemName: "cloud")
                            }
                            NavigationLink(destination: AppInfo()){
                                Image(systemName: "questionmark.circle")
                            }
                        }
                ).fullSize()
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ProjectRow: View {
    
    var project: ProjectData
    
    init(project: ProjectData){
        self.project=project
    }
    
    var body: some View {
        VStack(alignment: .leading){
            Text(project.name).font(.largeTitle).padding(.bottom)
            Section{
                Text("description".localize()+":").font(.headline)
                Text(project.description.isEmpty ? "none".localize() : project.description)
            }
            Section{
                ForEach(project.locations){
                    (location : LocationData) in
                    NavigationLink(destination: LocationView(location: location)){
                        NavigationRow(text: location.name)
                    }.padding(.leading)
                }
            }
        }.padding(.bottom)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectRow(project: ProjectData())
    }
}
