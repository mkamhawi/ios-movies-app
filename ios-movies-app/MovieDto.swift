//
//  Movie.swift
//  ios-movies-app
//
//  Created by mkamhawi on 8/22/17.
//  Copyright © 2017 Mohamed Elkamhawi. All rights reserved.
//

import Foundation
import ObjectMapper
import CoreData

class MovieDto: Mappable {
    var id: Int64!
    var title: String!
    var tagline: String?
    var status: String?
    var homepage: String?
    var posterPath: String?
    var backdropPath: String?
    var overview: String?
    var releaseDate: Date?
    var popularity: Double?
    var voteAverage: Float?
    var voteCount: Int32?
    var budget: Double?
    var revenue: Double?
    var runtime: Double?
    var generes: [GenreDto]?
    var productionCompanies: [CompanyDto]?
    var productionCountries: [CountryDto]?
    var spokenLanguages: [LanguageDto]?
    var trailers: [TrailerDto]?
    var reviews: [ReviewDto]?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        tagline <- map["tagline"]
        status <- map["status"]
        homepage <- map["homepage"]
        posterPath <- map["poster_path"]
        backdropPath <- map["backdrop_path"]
        overview <- map["overview"]
        releaseDate <- (map["release_date"], DateTransform())
        popularity <- map["popularity"]
        voteAverage <- map["vote_average"]
        voteCount <- map["vote_count"]
        budget <- map["budget"]
        revenue <- map["revenue"]
        runtime <- map["runtime"]
        generes <- map["generes"]
        productionCompanies <- map["production_companies"]
        productionCountries <- map["production_countries"]
        spokenLanguages <- map["spoken_languages"]
        trailers <- map["trailers"]["youtube"]
        reviews <- map["reviews"]["results"]
    }
    
    static func insert(movie: MovieDto, into category: Category, within context: NSManagedObjectContext) {
        let request: NSFetchRequest<Movie> = Movie.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", argumentArray: [movie.id])
            
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                assert(matches.count == 1, "MovieDto -- insert: database inconsistency")
                let existingMovie = matches[0]
                if let movieCategories = existingMovie.categories {
                    if movieCategories.contains(category) {
                        return
                    }
                }
                existingMovie.addToCategories(category)
            } else {
                let newMovie = Movie(context: context)
                newMovie.id = movie.id
                newMovie.title = movie.title
                newMovie.posterPath = movie.posterPath
                newMovie.backdropPath = movie.backdropPath
                newMovie.releaseDate = movie.releaseDate! as NSDate
                newMovie.overview = movie.overview
                newMovie.popularity = (movie.popularity ?? nil)!
                newMovie.voteCount = (movie.voteCount ?? nil)!
                newMovie.voteAverage = (movie.voteAverage ?? nil)!
                newMovie.addToCategories(category)
            }
        } catch {
            print("Error saving genre: \(error)")
        }
    }
    
    func update(completionHandler: @escaping () -> Void) {
        AppDelegate.persistentContainer.performBackgroundTask { context in
            let request: NSFetchRequest<Movie> = Movie.fetchRequest()
            request.predicate = NSPredicate(format: "id = %@", argumentArray: [self.id])
            
            do {
                let matches = try context.fetch(request)
                assert(matches.count == 1, "MovieDto -- update: database inconsistency")
                let movie = matches[0]
                
                movie.id = self.id
                movie.title = self.title
                movie.tagline = self.tagline
                movie.status = self.status
                movie.homepage = self.homepage
                movie.posterPath = self.posterPath
                movie.backdropPath = self.backdropPath
                movie.releaseDate = self.releaseDate! as NSDate
                movie.overview = self.overview
                movie.popularity = (self.popularity ?? nil)!
                movie.voteCount = (self.voteCount ?? nil)!
                movie.voteAverage = (self.voteAverage ?? nil)!
                movie.budget = (self.budget ?? nil)!
                movie.revenue = (self.revenue ?? nil)!
                movie.runtime = (self.runtime ?? nil)!
                
                self.generes?.forEach({ genreDto in
                    GenreDto.add(genreDto: genreDto, to: movie, with: context)
                })
                
                self.spokenLanguages?.forEach({ language in
                    LanguageDto.add(languageDto: language, to: movie, with: context)
                })
                
                self.productionCountries?.forEach({ country in
                    CountryDto.add(countryDto: country, to: movie, with: context)
                })
                
                self.productionCompanies?.forEach({ company in
                    CompanyDto.add(companyDto: company, to: movie, with: context)
                })
                
                if let savedReviews = movie.reviews {
                    movie.removeFromReviews(savedReviews)
                }
                
                self.reviews?.forEach({ newReview in
                    let review = Review(context: context)
                    review.id = newReview.id
                    review.author = newReview.author
                    review.content = newReview.content
                    review.url = newReview.url
                    
                    movie.addToReviews(review)
                })
                
                if let savedTrailers = movie.trailers {
                    movie.removeFromTrailers(savedTrailers)
                }
                
                self.trailers?.forEach({ newTrailer in
                    let trailer = Trailer(context: context)
                    trailer.name = newTrailer.name
                    trailer.size = newTrailer.size
                    trailer.source = newTrailer.source
                    trailer.type = newTrailer.type
                    
                    movie.addToTrailers(trailer)
                })
                
                try context.save()
                completionHandler()
            } catch {
                fatalError("MovieDto update: \(error)")
            }
        }
    }
}
