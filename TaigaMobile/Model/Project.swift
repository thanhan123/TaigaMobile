//
//  Project.swift
//  TaigaMobile
//
//  Created by Dinh Thanh An on 4/28/17.
//  Copyright © 2017 Dinh Thanh An. All rights reserved.
//

import Foundation

import Moya_ModelMapper
import Mapper

struct Project: Mappable {
    
    let name: String?
    let description: String?
    
    init(map: Mapper) throws {
        try name = map.from("name")
        try description = map.from("description")
    }
}
