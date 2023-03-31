//
//  RequestMaker.swift
//  FoodmanduSwiftUI
//
//  Created by manjil on 30/12/2022.
//

import Foundation
public struct File {
    
    public let name: String
    public let fileName: String
    public let data: Data
    public let contentType: String
    
    public init(name: String, fileName: String, data: Data, contentType: String) {
        self.name = name
        self.fileName = fileName
        self.data = data
        self.contentType = contentType
    }
}

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
    
    func makeMultiRequest<O>(multipart: [File]) async -> NetworkResult<ApiResponse<O>> {
        do {
            let request = try RequestBuilder(router: router, config: config).getMultipartRequest()
            let session  = URLSession(configuration: config.sessionConfiguration)
            return await tokenValidation(session, request: request.request, parameters: request.parameters, multipart: multipart)
        } catch {
            return .failure(NetworkingError(error))
        }
    }
    
    
    private func tokenValidation<O>(_ session: URLSession, request: URLRequest, parameters: Parameters = [:], multipart: [File] = []) async -> NetworkResult<ApiResponse<O>> {
        guard router.needsAuthorization else {
            return await checkMultipartThenRequest(session, request: request, parameters: parameters, multipart: multipart)
        }
        
        if tokenManager.isTokenValid() {
            return await checkMultipartThenRequest(session, request: request, parameters: parameters, multipart: multipart)
        }
        guard await refreshToken()  else {
            return .failure(NetworkingError("TOKEN_EXPIRE"))
        }
        return await checkMultipartThenRequest(session, request: request, parameters: parameters, multipart: multipart)
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
    
    private func checkMultipartThenRequest<O>(_ session: URLSession, request: URLRequest, parameters: Parameters, multipart: [File]) async -> NetworkResult<ApiResponse<O>> {
        if multipart.isEmpty {
            return  await normalRequest(session, request: request)
        }
        return await multipartRequest(session, request: request, parameters: parameters, multipart: multipart)
    }
    
    private func normalRequest<O>(_ session: URLSession, request: URLRequest) async -> NetworkResult<ApiResponse<O>> {
        await callApi(session, request: request)
    }
    
    private func multipartRequest<O>(_ session: URLSession, request: URLRequest, parameters: Parameters, multipart: [File]) async -> NetworkResult<ApiResponse<O>> {
        let boundary = UUID().uuidString
        var request = request
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let bodyData = createBodyWithMultipleImages(parameters: parameters, multipart: multipart, boundary: boundary)
        request.httpBody = bodyData
        
        return await callApi(session, request: request)
    }
    
    private func callApi<O>(_ session: URLSession, request: URLRequest)  async -> NetworkResult<ApiResponse<O>> {
        do {
            let  (data, response)   = try await session.data(for: request)
            Logger.log(response, request: request, data: data)
            let object =  try JSONDecoder().decode(ApiResponse<O>.self, from: data)
            return .success(NetworkingResponse.networkResponse(for: router, data: data, request: request, response: response, object: object))
        } catch {
            return .failure(NetworkingError(error))
        }
    }
    
    private func createBodyWithMultipleImages(parameters: Parameters, multipart: [File], boundary: String) -> Data {
        var body = Data()
        for (key, value) in parameters {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        multipart.forEach {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\($0.name)\"; filename=\"\($0.fileName)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: \($0.contentType)\r\n\r\n".data(using: .utf8)!)
            body.append($0.data)
            body.append("\r\n".data(using: .utf8)!)
        }
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }
}
