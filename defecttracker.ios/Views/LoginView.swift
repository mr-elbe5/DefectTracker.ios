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
    @State var showAlert1 = false;
    @State private var currentAlert : alertKey = .incomplete
    
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
                    Text("doLogin")
                }.alert(isPresented: $showAlert1){
                    switch currentAlert{
                    case .incomplete:
                        return Alert(title: Text("incomplete"), message:Text("fillAllFields"), dismissButton: .default(Text("ok")))
                    default:
                        return Alert(title: Text("error"), message:Text("loginError"), dismissButton: .default(Text("ok")))
                    }
                }
            }
            Section{
                Button(action: {
                    LoginController.shared.doLogout()
                }) {
                    Text("logout")
                }.disabled(!Store.shared.loginData.isLoggedIn())
            }
            HStack(){
                Spacer()
                Image(systemName: "keyboard.chevron.compact.down").onTapGesture {
                    self.dismissKeyboard()
                }
            }
        }.navigationBarTitle("login" ,displayMode: .inline)
            .modifier(KeyboardAdapter())
    }
    
    func doLogin() -> Void{
        if (self.isComplete()){
            LoginController.shared.doLogin(serverURL: self.serverURL, login: self.login, password: self.password){ (loggedIn) in
                if loggedIn{
                    DispatchQueue.main.async {
                        self.goBack()
                    }
                }
                else{
                    self.currentAlert = .error
                    self.showAlert1=true
                }
            }
        }
        else{
            self.currentAlert = .incomplete
            self.showAlert1=true
        }
    }
    
    func isComplete() -> Bool{
        return !self.serverURL.isEmpty && !self.login.isEmpty && !self.password.isEmpty
    }
    
    func goBack(){
        self.presentation.wrappedValue.dismiss()
    }
    
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
