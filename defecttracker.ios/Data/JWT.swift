//
//  JWT.swift
//  test.ios
//  Copyright (c) 2015 Auth0 (http://auth0.com)
//
//  Changes by Michael Rönnau on 08.04.20.
//  Copyright © 2020 Michael Rönnau. All rights reserved.
//

import Foundation

/**
*  Protocol that defines what a decoded JWT token should be.
*/
public protocol JWT {
    /// token header part contents
    var header: [String: Any] { get }
    /// token body part values or token claims
    var body: [String: Any] { get }
    /// token signature part
    var signature: String? { get }
    /// jwt string value
    var string: String { get }

    /// value of `exp` claim if available
    var expiresAt: Date? { get }
    /// value of `iss` claim if available
    var issuer: String? { get }
    /// value of `sub` claim if available
    var subject: String? { get }
    /// value of `aud` claim if available
    var audience: [String]? { get }
    /// value of `iat` claim if available
    var issuedAt: Date? { get }
    /// value of `nbf` claim if available
    var notBefore: Date? { get }
    /// value of `jti` claim if available
    var identifier: String? { get }

    /// Checks if the token is currently expired using the `exp` claim. If there is no claim present it will deem the token not expired
    var expired: Bool { get }
}

public extension JWT {

    /**
     Return a claim by it's name
     - parameter name: name of the claim in the JWT
     - returns: a claim of the JWT
     */
    func claim(name: String) -> Claim {
        let value = self.body[name]
        return Claim(value: value)
    }
}

public func decode(jwt: String) throws -> JWT {
    return try DecodedJWT(jwt: jwt)
}

struct DecodedJWT: JWT {

    let header: [String: Any]
    let body: [String: Any]
    let signature: String?
    let string: String

    init(jwt: String) throws {
        let parts = jwt.components(separatedBy: ".")
        guard parts.count == 3 else {
            throw DecodeError.invalidPartCount(jwt, parts.count)
        }

        self.header = try decodeJWTPart(parts[0])
        self.body = try decodeJWTPart(parts[1])
        self.signature = parts[2]
        self.string = jwt
    }

    var expiresAt: Date? { return claim(name: "exp").date }
    var issuer: String? { return claim(name: "iss").string }
    var subject: String? { return claim(name: "sub").string }
    var audience: [String]? { return claim(name: "aud").array }
    var issuedAt: Date? { return claim(name: "iat").date }
    var notBefore: Date? { return claim(name: "nbf").date }
    var identifier: String? { return claim(name: "jti").string }

    var expired: Bool {
        guard let date = self.expiresAt else {
            return false
        }
        return date.compare(Date()) != ComparisonResult.orderedDescending
    }
}

/**
 *  JWT Claim
 */
public struct Claim {

    /// raw value of the claim
    let value: Any?

    /// original claim value
    public var rawValue: Any? {
        return self.value
    }

    /// value of the claim as `String`
    public var string: String? {
        return self.value as? String
    }

    /// value of the claim as `Double`
    public var double: Double? {
        let double: Double?
        if let string = self.string {
            double = Double(string)
        } else {
            double = self.value as? Double
        }
        return double
    }

    /// value of the claim as `Int`
    public var integer: Int? {
        let integer: Int?
        if let string = self.string {
            integer = Int(string)
        } else if let double = self.value as? Double {
            integer = Int(double)
        } else {
            integer = self.value as? Int
        }
        return integer
    }

    /// value of the claim as `NSDate`
    public var date: Date? {
        guard let timestamp: TimeInterval = self.double else { return nil }
        return Date(timeIntervalSince1970: timestamp)
    }

    /// value of the claim as `[String]`
    public var array: [String]? {
        if let array = value as? [String] {
            return array
        }
        if let value = self.string {
            return [value]
        }
        return nil
    }
}

private func base64UrlDecode(_ value: String) -> Data? {
    var base64 = value
        .replacingOccurrences(of: "-", with: "+")
        .replacingOccurrences(of: "_", with: "/")
    let length = Double(base64.lengthOfBytes(using: String.Encoding.utf8))
    let requiredLength = 4 * ceil(length / 4.0)
    let paddingLength = requiredLength - length
    if paddingLength > 0 {
        let padding = "".padding(toLength: Int(paddingLength), withPad: "=", startingAt: 0)
        base64 += padding
    }
    return Data(base64Encoded: base64, options: .ignoreUnknownCharacters)
}

private func decodeJWTPart(_ value: String) throws -> [String: Any] {
    guard let bodyData = base64UrlDecode(value) else {
        throw DecodeError.invalidBase64Url(value)
    }

    guard let json = try? JSONSerialization.jsonObject(with: bodyData, options: []), let payload = json as? [String: Any] else {
        throw DecodeError.invalidJSON(value)
    }

    return payload
}

public enum DecodeError: LocalizedError {
    case invalidBase64Url(String)
    case invalidJSON(String)
    case invalidPartCount(String, Int)

    public var localizedDescription: String {
        switch self {
        case .invalidJSON(let value):
            return NSLocalizedString("Malformed jwt token, failed to parse JSON value from base64Url \(value)", comment: "Invalid JSON value inside base64Url")
        case .invalidPartCount(let jwt, let parts):
            return NSLocalizedString("Malformed jwt token \(jwt) has \(parts) parts when it should have 3 parts", comment: "Invalid amount of jwt parts")
        case .invalidBase64Url(let value):
            return NSLocalizedString("Malformed jwt token, failed to decode base64Url value \(value)", comment: "Invalid JWT token base64Url value")
        }
    }
}
