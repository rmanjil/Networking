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

protocol TokenManageable {
    func refreshToken() async -> Bool
    func isTokenValid() -> Bool
    var tokenParam: [String: String] {get }
    
}

class TokenManager: TokenManageable {
    
    func refreshToken() async -> Bool {
//        do {
//            let value = try  await Networking.default.dataRequest(router: AuthRouter.refreshToken(param), type: ApiResponse<AuthModel>.self)
//            token = try ekParser(value: value.data)
//            return true
//        } catch {
//            print(error.localizedDescription)
//        }
//        KeyChainManager().clear("TOKEN")
//        NotificationCenter.default.post(name: .tokenExpire, object: nil)
        return false
    }
    
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
    
    var param: Parameters {
        if let token {
            return ["grantType": "refresh_token", "refreshToken": token.refreshToken ?? ""]
        }
        return [:]
    }
    
    var tokenParam: [String: String] {
        if let token =  token,
           let accessToken = token.accessToken,
           let type = token.tokenType {
            return  ["Authorization": "\(type) \(accessToken)"]
        }
        
        return [:]
    }
}


extension NSNotification.Name {
    static let tokenExpire = NSNotification.Name("TOKEN_EXPIRE")
}

func ekParser<O: Decodable>(value: ApiResponse<O>) throws -> O {
    if let model = value.data {
        return model
    } else if let error = value.errors?.first {
        throw NetworkingError(error.detail ?? "ERROR_IS_MISSING_\(O.self)", code: error.code ?? 0)
    } else {
        throw NetworkingError("\(O.self)_MODEL_NOT_FOUND")
    }
}
