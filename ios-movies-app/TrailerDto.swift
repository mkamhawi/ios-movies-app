//
//  Trailer.swift
//  ios-movies-app
//
//  Created by mkamhawi on 8/22/17.
//  Copyright © 2017 Mohamed El-Kamhawi. All rights reserved.
//

import Foundation
import ObjectMapper

class TrailerDto: Mappable {
    var name: String!
    var size: String!
    var source: String!
    var type: String!

    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        name <- map["name"]
        size <- map["size"]
        source <- map["source"]
        type <- map["type"]
    }
}
