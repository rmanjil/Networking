//
//  RequestMaker.swift
//  FoodmanduSwiftUI
//
//  Created by manjil on 30/12/2022.
//

import Foundation

struct RequestMaker {
    typealias NetworkResult<O: Decodable> = (Result<NetworkingResponse<O>, NetworkingError>)
    private let router: NetworkingRouter
    private let config: NetworkingConfiguration
    private let tokenManager = TokenManager()
    
    init(router: NetworkingRouter, config: NetworkingConfiguration) {
        self.router = router
        self.config = config
    }
    
    
    func makeDataRequest<O>() async -> NetworkResult<ApiResponse<O>> {
        do {
            let request = try RequestBuilder(router: router, config: config).getRequest()
            let session  = URLSession(configuration: config.sessionConfiguration)
            return await tokenValidation(session, request: request)
        } catch {
            return .failure(NetworkingError(error))
        }
    }
    
    private func tokenValidation<O>(_ session: URLSession, request: URLRequest) async -> NetworkResult<ApiResponse<O>> {
        guard router.needsAuthorization else {
            return await normalRequest(session, request: request)
        }
        
        if tokenManager.isTokenValid() {
            return await normalRequest(session, request: request)
        }
        guard await refreshToken()  else {
            return .failure(NetworkingError("TOKEN_EXPIRE"))
        }
        return await normalRequest(session, request: request)
    }
    
    private func refreshToken() async -> Bool {
        do {
            let request = try RequestBuilder(router: UserRouter.home, config: config).getRequest()
            let session  = URLSession(configuration: config.sessionConfiguration)
            let result: NetworkResult<ApiResponse<AuthModel>> = await normalRequest(session, request: request)
            switch result {
            case .success(let response):
                guard let object = response.object?.data else {
                    return false
                }
                tokenManager.token = object
                print("object: \(object)")
                return true
            case .failure(let error):
                print(error.localizedDescription)
                return false
            }
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    private func normalRequest<O>(_ session: URLSession, request: URLRequest) async -> NetworkResult<ApiResponse<O>> {
        do {
            let  (data, response)   = try await session.data(for: request)
            Logger.log(response, request: request, data: data)
            let object =  try JSONDecoder().decode(ApiResponse<O>.self, from: data)
            return .success(NetworkingResponse.networkResponse(for: router, data: data, request: request, response: response, object: object))
        } catch {
            return .failure(NetworkingError(error))
        }
    }
}
