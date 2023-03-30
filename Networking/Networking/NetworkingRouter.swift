//
//  NetworkingRouter.swift
//  FoodmanduSwiftUI
//
//  Created by manjil on 30/12/2022.
//

import Foundation
protocol NetworkingRouter {
    
    /// The headers that will be passed by client to the request
    var headers: [String: String] { get }
    
    /// The endpoint path that will get appended to base path
    var path: String { get }
    
    /// The requests method
    var httpMethod: HTTPMethod { get }
    
    /// The encoders to use to be used for parameter encoding
    var encoder: [EncoderType] { get }
    
    /// The base URL to override if need be
    var overridenBaseURL: String? { get }
    
    var needsAuthorization: Bool {  get }
    
}

/// Deafult implementations
extension NetworkingRouter {
    var headers: [String: String] { [:] }
    var overridenBaseURL: String? { nil }
    var needsAuthorization: Bool {  false }
}

enum UserRouter: NetworkingRouter {
    case login(Parameters)
    case home
    case search
    var path: String  {
        switch self {
            
        case .login:
            return "token"
        case .home:
            return "General/HomePageLayoutV2"
        case .search:
            return "product/SearchInMultiVendor"

        }
    }
    
    
    var httpMethod: HTTPMethod {
        switch self {
            
        case .login:
           return .get
        case .home, .search:
            return .get
        }
    }
    
    var encoder: [EncoderType] {
        switch self {
            
        case .login(let parameter):
            return [.json(parameter)]
        case .home, .search:
            return [.json(nil)]
        }
    }
}


struct User: Decodable {
    var userName: String?
    var firstName: String?
}

