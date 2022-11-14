//
//  LoginView.swift
//  test.ios
//
//  Created by Michael Rönnau on 03.04.20.
//  Copyright © 2020 Michael Rönnau. All rights reserved.
//

import Foundation
import SwiftUI

struct LoginView: View{
    
    @State var serverURL = ""
    @State var login = ""
    @State var password = ""
    
    private enum alertKey{
        case incomplete, error
    }
    @State var showErrorAlert = false;
    @State private var currentError : alertKey = .incomplete
    @State var showSuccessAlert = false;
    
    @Environment(\.presentationMode) var presentation
    
    init(){
        let loginData = Store.shared.loginData
        self.serverURL = Store.shared.serverURL
        self.login = loginData.login
        self.password = ""
    }
    
    var body: some View{
        Form{
            Section{
                VStack(alignment: .leading){
                    VStack(alignment: .leading, spacing: 2){
                        Text("cloudURL")
                        TextField("https://...", text: self.$serverURL).withTextFieldStyle().keyboardType(.URL)
                    }
                    VStack(alignment: .leading, spacing: 2){
                        Text("loginName")
                        TextField("yourLoginName...", text: self.$login).withTextFieldStyle()
                    }
                    VStack(alignment: .leading, spacing: 2){
                        Text("password")
                        SecureField(".....", text: self.self.$password, onCommit: {() in
                            self.doLogin()
                        }).withTextFieldStyle()
                    }
                }
                
            }
            Section{
                Button(action: {
                    self.doLogin()
                }) {
                    Label("doLogin", systemImage: "person.fill.checkmark")
                }.alert(isPresented: $showErrorAlert){
                    switch currentError{
                    case .incomplete:
                        return Alert(title: Text("incomplete"), message:Text("fillAllFields"), dismissButton: .default(Text("ok")))
                    default:
                        return Alert(title: Text("error"), message:Text("loginError"), dismissButton: .default(Text("ok")))
                    }
                }
                .alert(isPresented: $showSuccessAlert){
                    return Alert(title: Text("success"), message:Text("successfullyLoggedIn"), dismissButton: .default(Text("ok")))
                }
            }
            Section{
                Button(action: {
                    LoginController.shared.doLogout()
                }) {
                    Label("logout", systemImage: "person.fill.xmark").foregroundColor(Color.red)
                }.disabled(!Store.shared.loginData.isLoggedIn())
            }
        }.navigationBarTitle("login" ,displayMode: .inline)
    }
    
    func doLogin() -> Void{
        if (self.isComplete()){
            Task{
                do{
                    if try await LoginController.shared.doLogin(serverURL: self.serverURL, login: self.login, password: self.password){
                        self.showSuccessAlert=true
                    }else{
                        self.currentError = .error
                        self.showErrorAlert=true
                    }
                } catch{
                    self.currentError = .error
                    self.showErrorAlert=true
                }
            }
        }
        else{
            self.currentError = .incomplete
            self.showErrorAlert=true
        }
    }
    
    func isComplete() -> Bool{
        return !self.serverURL.isEmpty && !self.login.isEmpty && !self.password.isEmpty
    }
    
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
