//
//  Store.swift
//  test.ios
//
//  Created by Michael Rönnau on 02.04.20.
//  Copyright © 2020 Michael Rönnau. All rights reserved.
//

import Foundation

class Store : ObservableObject{
    
    enum StoreKey: String, CaseIterable {
        case
        id,
        serverURL,
        loginData,
        projectList
    }
    
    public static var shared = Store()
    
    let store: UserDefaults
    
    private var id = 0
    @Published var serverURL = ""
    @Published var loginData = LoginData()
    @Published var projectList = ProjectList()
    
    private init() {
        self.store = UserDefaults.standard
    }
    
    func load(){
        id = getInt(forKey: StoreKey.id) ?? Statics.minNewId
        serverURL = getString(forKey: StoreKey.serverURL) ?? ""
        loginData = get(forKey: StoreKey.loginData) ?? LoginData()
        projectList = get(forKey: StoreKey.projectList) ?? ProjectList()
    }
    
    func saveProjectList(){
        store(forKey: StoreKey.projectList, value: projectList)
    }
    
    func saveLoginData(){
        store(forKey: StoreKey.serverURL, value: serverURL)
        store(forKey: StoreKey.loginData, value: loginData)
    }
    
    private func store(forKey key: StoreKey, value: String) {
        store.set(value, forKey: key.rawValue)
    }
    private func store(forKey key: StoreKey, value: Int) {
        store.set(value, forKey: key.rawValue)
    }
    private func store(forKey key: StoreKey, value: Bool) {
        store.set(value, forKey: key.rawValue)
    }
    private func store(forKey key: StoreKey, value: Codable) {
        let storeString = value.serialize()
        store.set(storeString, forKey: key.rawValue)
    }
    
    private func getString(forKey key: StoreKey) -> String? {
        return store.value(forKey: key.rawValue) as? String
    }
    
    private func getInt(forKey key: StoreKey) -> Int? {
        return store.value(forKey: key.rawValue) as? Int
    }
    
    private func getBool(forKey key: StoreKey) -> Bool? {
        return store.value(forKey: key.rawValue) as? Bool
    }
    
    private func get<T : Codable>(forKey key: StoreKey) -> T? {
        if let storedString = store.value(forKey: key.rawValue) as? String {
            return T.deserialize(encoded: storedString)
        }
        return nil
    }
    
    //MARK : publics
    
    public func setServerURL(url : String){
        DispatchQueue.main.async{
            self.serverURL=url
        }
        store(forKey: StoreKey.serverURL, value: url)
    }
    
    public func setLoginData(data : LoginData){
        DispatchQueue.main.async{
            self.loginData = data
        }
        store(forKey: StoreKey.loginData, value: data)
    }
    
    public func setProjectList(data : ProjectList){
        DispatchQueue.main.async{
            self.projectList = data
        }
        store(forKey: StoreKey.projectList, value: data)
    }
    
    public func getNextId() -> Int{
        self.id = (self.id + 1)
        print("next id = \(self.id)")
        store(forKey: .id, value: self.id)
        return self.id
    }
    
}
