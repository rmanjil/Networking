//
//  ResponseMessage.swift
//  PracticalAction
//
//  Created by manjil on 29/03/2023.
//

import Foundation

public struct ResponseMessage: Decodable {
    
    public var title : String?
    public var detail : String?
    public var code: String?
    
    init(detail: String) {
        self.detail = detail
    }
    
    enum CodingKeys: String, CodingKey {
        case title
        case detail
        case code
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decodeIfPresent(String.self, forKey: .title) 
        detail = try container.decodeIfPresent(String.self, forKey: .detail)
        code = try container.decodeIfPresent(String.self, forKey: .code)
    }
    
}
