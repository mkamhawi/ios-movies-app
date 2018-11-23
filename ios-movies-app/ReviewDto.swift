//
//  Review.swift
//  ios-movies-app
//
//  Created by mkamhawi on 8/22/17.
//  Copyright © 2017 Mohamed El-Kamhawi. All rights reserved.
//

import Foundation
import ObjectMapper

class ReviewDto: Mappable {
    var id: String!
    var author: String!
    var content: String!
    var url: String!

    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        author <- map["author"]
        content <- map["content"]
        url <- map["url"]
    }
}
