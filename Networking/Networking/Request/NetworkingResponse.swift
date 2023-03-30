//
//  NetworkingResponse.swift
//  FoodmanduSwiftUI
//
//  Created by manjil on 30/12/2022.
//

import Foundation

struct NetworkingResponse<T: Decodable> {
    let data: Data?
    let object: T?
    let urlRequest: URLRequest
    let urlResponse: URLResponse?
    let router: NetworkingRouter
    let statusCode: Int
    
    static func networkResponse(for router: NetworkingRouter, data: Data, request: URLRequest, response: URLResponse, object: T?) -> NetworkingResponse {
        guard let urlResponse = response as? HTTPURLResponse else {
            return NetworkingResponse(data: data, object: object, urlRequest: request, urlResponse: response, router: router, statusCode: 0)
        }
        return NetworkingResponse(data: data, object: object, urlRequest: request, urlResponse: response, router: router, statusCode: urlResponse.statusCode)
    }
}
