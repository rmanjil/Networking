//
//  Container.swift
//  PracticalAction
//
//  Created by manjil on 29/03/2023.
//

import Foundation

protocol Container: Decodable {
    
    var errors: [ResponseMessage]? { get }
    var hasData: Bool { get }
}
