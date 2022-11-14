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
        case success, incomplete, error
    }
    
    @State var showAlert = false
    @State private var currentAlert : alertKey = .success
    
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
                }.alert(isPresented: $showAlert){
                    return Alert(title: Text(getAlertTitle()), message:Text(getAlertText()), dismissButton: .default(Text("ok")))
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
                        self.currentAlert = .success
                        self.showAlert=true
                    }else{
                        self.currentAlert = .error
                        self.showAlert=true
                    }
                } catch{
                    self.currentAlert = .error
                    self.showAlert=true
                }
            }
        }
        else{
            self.currentAlert = .incomplete
            self.showAlert=true
        }
    }
    
    func isComplete() -> Bool{
        return !self.serverURL.isEmpty && !self.login.isEmpty && !self.password.isEmpty
    }
    
    func getAlertTitle() -> String{
        switch currentAlert{
        case .success:
            return "success".localize()
        case .incomplete:
            return "incomplete".localize()
        default:
            return "error".localize()
        }
    }
    
    func getAlertText() -> String{
        switch currentAlert{
        case .success:
            return "successfullyLoggedIn".localize()
        case .incomplete:
            return "fillAllFields".localize()
        default:
            return "loginError".localize()
        }
    }
    
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
