//
//  NetworkOperations.swift
//  ios-movies-app
//
//  Created by mkamhawi on 8/19/17.
//  Copyright © 2017 Mohamed El-Kamhawi. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

class NetworkOperations {
    
    private let baseUrl: String = "https://api.themoviedb.org/3/movie"
    public private(set) var posterBaseUrl: String = "https://image.tmdb.org/t/p/w185"
    public private(set) var youtubeBaseUrl: String = "https://www.youtube.com/watch"
    private let apiKey: String
    
    init() {
        apiKey = Utilities().getApiKey()
    }
    
    public func getMovies(category: String, page: Int, completionHandler: @escaping () -> Void) {
        let parameters = [
            "api_key": apiKey,
            "page": String(page)
        ]
        
        AF
            .request(baseUrl + "/" + category, parameters: parameters)
            .response(completionHandler: { (result) in
                if let data = result.data, let movies = String(data: data, encoding: .utf8) {
                    print("Request: \(String(describing: result.request))")   // original url request
                    print("Response: \(String(describing: result.response))") // http url response
                    let movieCollection = Mapper<MovieCollectionDto>()
                        .map(JSONString: movies)
                    
                    movieCollection?.insert(into: category, deleteOldData: page == 1, completionHandler: completionHandler)
                } else {
                    print("Error: NetworkOperation getMovies: \(String(describing: result.error))")
                }
            })
    }
    
    public func getMovieDetails(movieId: Int64, completionHandler: @escaping () -> Void) {
        let parameters = [
            "api_key": apiKey,
            "append_to_response": "trailers,reviews"
        ]
        
        AF
            .request(baseUrl + "/" + String(movieId), parameters: parameters)
            .response(completionHandler: { (result) in
                if let data = result.data, let movie = String(data: data, encoding: .utf8) {
                    print("Request: \(String(describing: result.request))")   // original url request
                    print("Response: \(String(describing: result.response))") // http url response
                    let movieDetails = Mapper<MovieDto>()
                        .map(JSONString: movie)
                    
                    movieDetails?.update(completionHandler: completionHandler)
                } else {
                    print("Error: NetworkOperation getMovieDetails: \(String(describing: result.error))")
                }
            })
    }
}
