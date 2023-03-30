//
//  RequestBuilder.swift
//  FoodmanduSwiftUI
//
//  Created by manjil on 30/12/2022.
//

import Foundation

/// The struct for building the request with information from router
struct RequestBuilder {
    
    /// The router of the request
    let router: NetworkingRouter
    
    /// The session config
    let config: NetworkingConfiguration
    
    /// Gets the request with config and router info
    /// - Returns: The URLResquest to use
    func getRequest() throws -> URLRequest {
        let baseURL = router.overridenBaseURL ?? config.baseURL
        guard let url = URL(string: baseURL)?.appendingPathComponent(router.path) else {
            throw NetworkingError(.invalidBaseURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = router.httpMethod.identifier
        router.headers.forEach({ request.addValue($0, forHTTPHeaderField: $1) })
        request.addValue(config.clientId, forHTTPHeaderField: "client_id")
        request.addValue(config.clientSecret, forHTTPHeaderField: "client_secret")
        if let token = TokenManager().token?.accessToken {
            request.addValue("bearer " + token, forHTTPHeaderField: "client_secret")
        }
        try router.encoder.forEach { type in
            switch type {
            case .json(let params):
                try request.jsonEncoding(params)
            case .url(let params):
                try request.urlEncoding(params)
            }
        }
        return request
    }
}
