//
//  NetworkingConfiguration.swift
//  FoodmanduSwiftUI
//
//  Created by manjil on 30/12/2022.
//

import Foundation

struct NetworkingConfiguration {
    
    /// The baseURL for the API
    let baseURL: String
    let clientId: String
    let clientSecret: String
    
    /// The url session connfiguration
    let sessionConfiguration: URLSessionConfiguration
    
    public init(baseURL: String, clientId: String, clientSecret: String, sessionConfiguration: URLSessionConfiguration = URLSessionConfiguration.default) {
        self.baseURL = baseURL
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.sessionConfiguration = sessionConfiguration
    }
    
    /// The configuration information
    public func debugInfo() -> [String: Any] {
        [
            "baseURL": baseURL,
            "sessionConfiguration": sessionConfiguration,
        ]
    }
}
