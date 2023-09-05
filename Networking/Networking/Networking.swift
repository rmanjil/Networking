//
//  Networking.swift
//  FoodmanduSwiftUI
//
//  Created by manjil on 02/01/2023.
//

import Foundation

protocol NetworkConformable {
    static func initialize(with config: NetworkingConfiguration)
    func dataRequest<T>(router: NetworkingRouter ,type: T.Type) async throws -> T?
    func dataRequest<O>(router: NetworkingRouter ,type: O.Type) async throws -> Response<O>
    func multipartRequest<O>(router: NetworkingRouter, multipart: [File], type: O.Type) async throws -> Response<O>
}

struct Response<T: Decodable> {
    var data: T
    var meta: Meta?
    var statusCode: Int
}

class Networking: NetworkConformable {
    func dataRequest<T>(router: NetworkingRouter, type: T.Type) async throws -> T? {
        nil
    }
    
    /// make the instance shared
    public static let `default` = Networking()
    private init() {}
    
    /// The networking configuration
    private var config: NetworkingConfiguration?
    
    /// Method to set the configuration from client side
    /// - Parameter config: The networking configuration
    static func initialize(with config: NetworkingConfiguration) {
        Networking.default.config = config
        _ = Connectivity.default
    }
    
    /// Method to create a response publisher for data
    func dataRequest<O>(router: NetworkingRouter, type: O.Type)  async throws ->  Response<O> {
        try  await createAndPerformRequest(router, multipart: [])
    }
    
    /// Method to create a response publisher for data
    func multipartRequest<O>(router: NetworkingRouter, multipart: [File], type: O.Type) async throws -> Response<O> {
        try await createAndPerformRequest(router, multipart: multipart)
    }
    
    private func createAndPerformRequest<O>(_ router: NetworkingRouter, multipart: [File]) async throws ->  Response<O> {
        guard let config = Networking.default.config else {
            throw NetworkingError(.networkingNotInitialized)
        }
        
        guard Connectivity.default.status == .connected else {
            throw NetworkingError(.noConnectivity)
        }
        let requestMaker = RequestMaker(router: router, config: config)
        
        let result: RequestMaker.NetworkResult<O> = await (multipart.isEmpty ?   requestMaker.makeDataRequest() :  requestMaker.makeMultiRequest(multipart: multipart))
        
        switch result {
            case .success(let data):
                if let model = data.object {
                    let response = Response(data: model, statusCode: data.statusCode)
                    return response
                }
            case .failure(let error):
                throw error
        }
        
        throw NetworkingError("SOMETHING_WENT_WRONG")
    }
}
