//
//  ApiResponse.swift
//  PracticalAction
//
//  Created by manjil on 29/03/2023.
//

import Foundation

public struct ApiResponse<T: Decodable>: Container {
    
    var data: T?
    var errors: [ResponseMessage]?
    var meta: Meta?
    var hasData: Bool {
        return data != nil
    }
    
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        data = try container.decodeIfPresent(T.self, forKey: .data)
//        errors = try container.decodeIfPresent([ResponseMessage].self, forKey: .errors)
//        meta = try container.decodeIfPresent(Meta.self, forKey: .meta)
//    }
}
