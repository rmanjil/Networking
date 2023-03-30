//
//  Meta.swift
//  PracticalAction
//
//  Created by manjil on 29/03/2023.
//

import Foundation

struct Meta: Decodable {
    
    var pagination : Pagination?
    
    enum CodingKeys: String, CodingKey {
        case pagination
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        pagination = try container.decodeIfPresent(Pagination.self, forKey: .pagination)
    }
}
