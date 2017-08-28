//
//  Language.swift
//  ios-movies-app
//
//  Created by mkamhawi on 8/22/17.
//  Copyright © 2017 Mohamed Elkamhawi. All rights reserved.
//

import Foundation
import ObjectMapper
import CoreData

class LanguageDto: Mappable {
    var isoCode: String!
    var name: String!
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        isoCode <- map["iso_639_1"]
        name <- map["name"]
    }
    
    static func add(languageDto: LanguageDto, to movie: Movie, with context: NSManagedObjectContext) {
        let uniqnessPredicate = NSPredicate(format: "isoCode = %@", argumentArray: [languageDto.isoCode])
        let language = Utilities.findOrCreate(
            typeDto: languageDto,
            with: uniqnessPredicate,
            coreDataTypeFactory: { () -> Language in
                let language = Language(context: context)
                language.isoCode = languageDto.isoCode
                language.name = languageDto.name
                return language
        },
            within: context
        )
        language.addToMovies(movie)
    }
}
