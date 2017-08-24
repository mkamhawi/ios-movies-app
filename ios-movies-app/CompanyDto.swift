//
//  Company.swift
//  ios-movies-app
//
//  Created by mkamhawi on 8/22/17.
//  Copyright © 2017 Mohamed Elkamhawi. All rights reserved.
//

import Foundation
import ObjectMapper
import CoreData

class CompanyDto: Mappable {
    var id: Int32!
    var name: String!

    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
    }
    
    static func add(companyDto: CompanyDto, to movie: Movie, with context: NSManagedObjectContext) {
        let uniqnessPredicate = NSPredicate(format: "id = %@", argumentArray: [companyDto.id])
        let company = Utilities.findOrCreate(
            typeDto: companyDto,
            with: uniqnessPredicate,
            coreDataTypeFactory: { () -> Company in
                let company = Company(context: context)
                company.id = companyDto.id
                company.name = companyDto.name
                return company
        },
            within: context
        )
        company.addToMovies(movie)
    }
}
