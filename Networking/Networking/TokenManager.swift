//
//  TokenManager.swift
//  PracticalAction
//
//  Created by manjil on 29/03/2023.
//

import Foundation


public class AuthModel: Codable {
    
    public var tokenType: String?
    public var expiresIn: Double?
    public var accessToken: String?
    public var refreshToken: String?
    public var date: Date?
   //// public var errors: [ResponseMessage]?
    //required for showing/hiding change password option
    public var isFromSocialMedia: Bool?
    
    enum CodingKeys: String, CodingKey {
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case date
        //case errors
        case isFromSocialMedia
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        tokenType = try container.decodeIfPresent(String?.self, forKey: .tokenType) ?? nil
        expiresIn = try container.decodeIfPresent(Double?.self, forKey: .expiresIn) ??  nil
        accessToken = try container.decodeIfPresent(String?.self, forKey: .accessToken) ?? nil
        refreshToken = try container.decodeIfPresent(String?.self, forKey: .refreshToken) ?? nil
        date = try container.decodeIfPresent(Date?.self, forKey: .date) ?? nil
      //  errors = try container.decodeIfPresent([ResponseMessage]?.self, forKey: .errors) ?? nil
        isFromSocialMedia = try container.decodeIfPresent(Bool?.self, forKey: .isFromSocialMedia) ?? nil
    }
    
}

class TokenManager {
    var token: AuthModel? {
        set {
            if let newValue {
                KeyChainManager.standard.set(object: newValue, forKey: "TOKEN")
            }
        } get {
            return  KeyChainManager.standard.retrieve(type: AuthModel.self, forKey: "TOKEN")
        }
    }
    
    func isTokenValid() -> Bool {
        if let time = token?.expiresIn, let date = token?.date {
            let expiryDate = date.addingTimeInterval(time)
            return Date().compare(expiryDate) == ComparisonResult.orderedAscending
        }
        return false
    }
}
