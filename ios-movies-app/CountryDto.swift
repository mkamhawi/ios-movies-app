//
//  Country.swift
//  ios-movies-app
//
//  Created by mkamhawi on 8/22/17.
//  Copyright © 2017 Mohamed El-Kamhawi. All rights reserved.
//

import Foundation
import ObjectMapper
import CoreData

class CountryDto: Mappable {
    var isoCode: String!
    var name: String!

    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        isoCode <- map["iso_3166_1"]
        name <- map["name"]
    }
    
    static func add(countryDto: CountryDto, to movie: Movie, with context: NSManagedObjectContext) {
        let uniqnessPredicate = NSPredicate(format: "isoCode = %@", argumentArray: [countryDto.isoCode])
        let country = Utilities.findOrCreate(
            typeDto: countryDto,
            with: uniqnessPredicate,
            coreDataTypeFactory: { () -> Country in
                let country = Country(context: context)
                country.isoCode = countryDto.isoCode
                country.name = countryDto.name
                return country
            },
            within: context
        )
        country.addToMovies(movie)
    }
}
