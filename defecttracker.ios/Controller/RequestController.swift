//
//  RequestController.swift
//  test.ios
//
//  Created by Michael Rönnau on 08.04.20.
//  Copyright © 2020 Michael Rönnau. All rights reserved.
//

import Foundation
import SwiftUI

struct RequestController {
    
    public static var shared = RequestController()
    
    func hasServerURL() -> Bool{
        return !Store.shared.serverURL.isEmpty
    }
    
    private func createRequest(url : String, method: String, headerFields : [String : String]?, params : [String:String]?) -> URLRequest? {
        var body : Data;
        if let params = params{
            do {
                body = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            } catch {
                print("could not create URLRequest: parameters could not be serialized")
                return nil
            }
        }
        else{
            body = Data();
        }
        return createRequest(url: url, method: method, headerFields: headerFields, body: body)
    }
    
    private func createRequest(url : String, method: String, headerFields : [String : String]?, body: Data) -> URLRequest? {
        guard let requestUrl = URL(string : url) else {
            print("could not create URLRequest: URL could not be created")
            return nil
        }
        var request = URLRequest(url : requestUrl)
        request.httpMethod=method
        if let headerFields = headerFields{
            for key: String in headerFields.keys {
                if let val = headerFields[key] {
                    request.addValue(val, forHTTPHeaderField: key)
                }
            }
        }
        request.httpBody = body;
        return request
    }
    
    //todo
    func requestJson<T : Decodable>(url : String, withParams params : [String:String]?, callback: @escaping (T?, Error?) -> Void){
        if let urlRequest = createRequest(url: url, method: "POST", headerFields:
            ["Content-Type" : "application/json",
             "Accept" : "application/json"
        ], params: params){
            return launchJsonRequest(with: urlRequest, callback: callback)
        }
        else{
            callback(nil, RequestError.invalidRequest)
        }
    }
    
    //todo
    func requestAuthorizedJson<T : Decodable>(url : String, withParams params : [String:String]?, callback: @escaping (T?, Error?) -> Void){
        if let urlRequest = createRequest(url: url, method: "POST", headerFields:[
            "Content-Type" : "application/json",
            "Accept" : "application/json",
            "Authentication" : Store.shared.loginData.token
        ], params: params){
            launchJsonRequest(with: urlRequest, callback: callback)
        }
        else{
            callback(nil, RequestError.invalidRequest)
        }
    }
    
    func requestAuthorizedImage(url : String, withParams params : [String:String]?, callback: @escaping (UIImage?, Error?) -> Void){
        if let urlRequest = createRequest(url: url, method: "POST", headerFields: [
            "Content-Type" : "application/json",
            "Accept" : "application/json",
            "Authentication" : Store.shared.loginData.token
        ], params: params){
            launchImageRequest(with: urlRequest, callback: callback)
        }
        else{
            callback(nil, RequestError.invalidRequest)
        }
    }
    
    func uploadAuthorizedImage<T : Decodable>(url : String, withImage uiImage : UIImage,fileName: String, callback: @escaping (T?, Error?) -> Void){
        if let data = uiImage.jpegData(compressionQuality: 0.8) {
            if let urlRequest = createRequest(url: url, method: "POST", headerFields: [
                "Content-Type" : "application/octet-stream",
                "contentType" : "image/jpeg",
                "fileName" : fileName,
                "Accept" : "application/json",
                "Authentication" : Store.shared.loginData.token
            ], body: data){
                launchJsonRequest(with: urlRequest, callback: callback)
            }
        }
        else{
            callback(nil, RequestError.invalidRequest)
        }
    }
    
    private func launchJsonRequest<T : Decodable>(with request : URLRequest, callback: @escaping (T?, Error?) -> Void){
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            var statusCode = 0
            if (response != nil && response is HTTPURLResponse){
                let httpResponse = response! as! HTTPURLResponse
                statusCode = httpResponse.statusCode
            }
            if let error = error {
                print(error)
                callback(nil, error)
            } else if (statusCode>0 && statusCode != 200 ){
                callback(nil, ResponseError(code: statusCode))
            } else {
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .millisecondsSince1970
                    let object = try decoder.decode(T.self, from: data!)
                    callback(object, nil)
                } catch let error{
                    print(error)
                    callback(nil, RequestError.unexpectedResponse)
                }
            }
        }
        task.resume()
    }
    
    private func launchImageRequest(with request : URLRequest, callback: @escaping (UIImage?, Error?) -> Void){
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            var statusCode = 0
            if (response != nil && response is HTTPURLResponse){
                let httpResponse = response! as! HTTPURLResponse
                statusCode = httpResponse.statusCode
            }
            if let error = error {
                callback(nil, error)
            } else if (statusCode>0 && statusCode != 200 ){
                callback(nil, ResponseError(code: statusCode))
            } else {
                do {
                    if let image = UIImage(data: data!){
                        //print("image received from server")
                        callback(image, nil)
                    }
                    else {
                        callback(nil, RequestError.unexpectedResponse)
                    }
                }
            }
        }
        task.resume()
    }
    
}



