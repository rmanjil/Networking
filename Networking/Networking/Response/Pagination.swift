//
//  Pagination.swift
//  PracticalAction
//
//  Created by manjil on 29/03/2023.
//

import Foundation

public struct Pagination: Decodable {
    
    public var totalPages : Int?
    public var currentPage: Int?
    var perPage: Int?
    
    enum CodingKeys: String, CodingKey {
        case totalPages = "total_pages",
             perPage = "per_page",
             currentPage = "current_page"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        totalPages = try container.decodeIfPresent(Int.self, forKey: .totalPages)
        currentPage = try container.decodeIfPresent(Int.self, forKey: .currentPage)
        perPage = try container.decodeIfPresent(Int.self, forKey: .perPage)
    }
}
