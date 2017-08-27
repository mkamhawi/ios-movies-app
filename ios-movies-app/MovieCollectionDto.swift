//
//  MovieCollectionDto.swift
//  ios-movies-app
//
//  Created by mkamhawi on 8/22/17.
//  Copyright © 2017 Mohamed Elkamhawi. All rights reserved.
//

import Foundation
import ObjectMapper
import CoreData

class MovieCollectionDto: Mappable {
    var page: Int!
    var totalPages: Int!
    var totalResults: Int!
    var results: [MovieDto]?

    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        page <- map["page"]
        totalPages <- map["total_pages"]
        totalResults <- map["total_results"]
        results <- map["results"]
    }
    
    func insert(into categoryName: String, deleteOldData: Bool, completionHandler: @escaping () -> Void) {
        AppDelegate.persistentContainer.performBackgroundTask { context in
            let request: NSFetchRequest<Category> = Category.fetchRequest()
            request.predicate = NSPredicate(format: "name = %@", argumentArray: [categoryName])
            
            do{
                let matches = try context.fetch(request)
                var category: Category
                if matches.count > 0 {
                    assert(matches.count == 1, "MovieCollectionDto -- insert: database inconsistency")
                    category = matches[0]
                } else {
                    category = Category(context: context)
                    category.name = categoryName
                }
                
                if deleteOldData {
                    category.movies?.forEach({ movie in
                        context.delete(movie as! NSManagedObject)
                    })
                }
                
                for movie in self.results! {
                    MovieDto.insert(movie: movie, into: category, within: context)
                }
                do {
                    try context.save()
                    completionHandler()
                } catch {
                    print("Error: MovieCollectionDto.insert(): \(error)")
                }
            } catch {
                print("Error: MovieCollectionDto.insert(): \(error)")
            }
        }
    }
}
