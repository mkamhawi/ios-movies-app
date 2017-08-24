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
                newMovie.popularity = movie.popularity!
                newMovie.voteCount = movie.voteCount!
                newMovie.voteAverage = movie.voteAverage!
                newMovie.addToCategories(category)
            }
        } catch {
            print("Error saving genre: \(error)")
        }
    }
    
    static func update(movieDto: MovieDto) {
        AppDelegate.persistentContainer.performBackgroundTask { context in
            let request: NSFetchRequest<Movie> = Movie.fetchRequest()
            request.predicate = NSPredicate(format: "id = %@", argumentArray: [movieDto.id])
            
            do {
                let matches = try context.fetch(request)
                assert(matches.count == 1, "MovieDto -- update: database inconsistency")
                let movie = matches[0]
                
                movie.id = movieDto.id
                movie.title = movieDto.title
                movie.tagline = movieDto.tagline
                movie.status = movieDto.status
                movie.homepage = movieDto.homepage
                movie.posterPath = movieDto.posterPath
                movie.backdropPath = movieDto.backdropPath
                movie.releaseDate = movieDto.releaseDate! as NSDate
                movie.overview = movieDto.overview
                movie.popularity = movieDto.popularity!
                movie.voteCount = movieDto.voteCount!
                movie.voteAverage = movieDto.voteAverage!
                movie.budget = movieDto.budget!
                movie.revenue = movieDto.revenue!
                movie.runtime = movieDto.runtime!
                
                movieDto.generes?.forEach({ genreDto in
                    GenreDto.add(genreDto: genreDto, to: movie, with: context)
                })
                
                movieDto.spokenLanguages?.forEach({ language in
                    LanguageDto.add(languageDto: language, to: movie, with: context)
                })
                
                movieDto.productionCountries?.forEach({ country in
                    CountryDto.add(countryDto: country, to: movie, with: context)
                })
                
                movieDto.productionCompanies?.forEach({ company in
                    CompanyDto.add(companyDto: company, to: movie, with: context)
                })
                
                if let savedReviews = movie.reviews {
                    movie.removeFromReviews(savedReviews)
                }
                
                movieDto.reviews?.forEach({ newReview in
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
                
                movieDto.trailers?.forEach({ newTrailer in
                    let trailer = Trailer(context: context)
                    trailer.name = newTrailer.name
                    trailer.size = newTrailer.size
                    trailer.source = newTrailer.source
                    trailer.type = newTrailer.type
                    
                    movie.addToTrailers(trailer)
                })
                
                try context.save()
            } catch {
                fatalError("MovieDto update: \(error)")
            }
        }
    }
}
