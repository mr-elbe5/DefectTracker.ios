//
//  LoginController.swift
//  test.ios
//
//  Created by Michael Rönnau on 04.04.20.
//  Copyright © 2020 Michael Rönnau. All rights reserved.
//

import Foundation
import Then

class LoginController {
    
    public static var shared = LoginController()
    
    //todo
    func doLogin(serverURL: String, login: String, password: String) -> Promise<LoginData>{
        return Promise { resolve, reject in
            var url = serverURL
            if url.hasSuffix("/"){
                url=String(url.dropLast(1))
            }
            let requestUrl = url+"/api/user/login"
            let params = [
                "login" : login,
                "password" : password,
            ]
            RequestController.shared.requestJson(url: requestUrl, withParams: params).then {
                (loginData : LoginData) in
                if (loginData.isLoggedIn()){
                    DispatchQueue.main.async{
                        Store.shared.setServerURL(url: url)
                        Store.shared.setLoginData(data: loginData)
                    }
                    //print("\(loginData.dump())")
                    resolve(loginData)
                }
                else{
                    reject(RequestError.unexpectedResponse)
                }
            }.onError{
                (e) in
                reject(e)
            }
            
        }
        
    }
    
    func doLogout() -> Void{
        let loginData = Store.shared.loginData
        loginData.token = ""
        DispatchQueue.main.async{
            Store.shared.setLoginData(data: loginData)
        }
    }
    
}
