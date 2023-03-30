//
//  Networking.swift
//  FoodmanduSwiftUI
//
//  Created by manjil on 02/01/2023.
//

import Foundation

protocol NetworkConformable {
    static func initialize(with config: NetworkingConfiguration)
    func dataRequest<O>(router: NetworkingRouter ,type: O.Type) async -> RequestMaker.NetworkResult<ApiResponse<O>>
    func multipartRequest<O>(router: NetworkingRouter, multipart: [File], type: O.Type) async -> RequestMaker.NetworkResult<ApiResponse<O>>
}

class Networking: NetworkConformable {
    
    /// make the instance shared
    public static let `default` = Networking()
    private init() {}
    
    /// The networking configuration
    private var config: NetworkingConfiguration?
    
    /// Method to set the configuration from client side
    /// - Parameter config: The networking configuration
    static func initialize(with config: NetworkingConfiguration) {
        Networking.default.config = config
    }
    
    /// Method to create a response publisher for data
    func dataRequest<O>(router: NetworkingRouter, type: O.Type) async -> RequestMaker.NetworkResult<ApiResponse<O>> where O : Decodable {
        await createAndPerformRequest(router, config: Networking.default.config, multipart: [])
    }
    
    /// Method to create a response publisher for data
    func multipartRequest<O>(router: NetworkingRouter, multipart: [File], type: O.Type) async -> RequestMaker.NetworkResult<ApiResponse<O>> where O : Decodable {
        await createAndPerformRequest(router, config: Networking.default.config, multipart: multipart)
    }
    
     private func createAndPerformRequest<O>(_ router: NetworkingRouter, config: NetworkingConfiguration?, multipart: [File]) async -> RequestMaker.NetworkResult<ApiResponse<O>> {
        guard let config = config else {
            return .failure(NetworkingError(.networkingNotInitialized))
        }
        
        guard Connectivity.default.status == .connected else {
            return .failure(NetworkingError(.noConnectivity))
        }
        let requestMaker = RequestMaker(router: router, config: config)
        return multipart.isEmpty ? await requestMaker.makeDataRequest() :  await requestMaker.makeMultiRequest(multipart: multipart)
    }
}

