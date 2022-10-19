//
//  Error.swift
//  test.ios
//
//  Created by Michael Rönnau on 08.04.20.
//  Copyright © 2020 Michael Rönnau. All rights reserved.
//

import Foundation

enum RequestError: Swift.Error {
    case invalidURL
    case invalidRequest
    case unauthorizedRequest
    case unexpectedResponse
}

struct ResponseError: Swift.Error {
    var responseCode : Int
    
    init(code : Int){
        responseCode=code
    }
}

extension RequestError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .invalidRequest: return "Invalid Request Data"
        case .unauthorizedRequest: return "No Authorization in Request Data"
        case .unexpectedResponse: return "Unexpected response from the server"
        }
    }
}

extension ResponseError: LocalizedError {
    var errorDescription: String? {
        return "Response code is \(responseCode)"
    }
}
