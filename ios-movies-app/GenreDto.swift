//
//  Genre.swift
//  ios-movies-app
//
//  Created by mkamhawi on 8/22/17.
//  Copyright © 2017 Mohamed El-Kamhawi. All rights reserved.
//

import Foundation
import ObjectMapper
import CoreData

class GenreDto: Mappable {
    var id: Int32!
    var name: String!
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
    }
    
    static func add(genreDto: GenreDto, to movie: Movie, with context: NSManagedObjectContext) {
        let uniqnessPredicate = NSPredicate(format: "id = %@", argumentArray: [genreDto.id])
        let genre = Utilities.findOrCreate(
            typeDto: genreDto,
            with: uniqnessPredicate,
            coreDataTypeFactory: { () -> Genre in
                let genre = Genre(context: context)
                genre.id = genreDto.id
                genre.name = genreDto.name
                return genre
            },
            within: context
        )
        
        genre.addToMovies(movie)
    }
}
