//
//  NetworkOperations.swift
//  ios-movies-app
//
//  Created by mkamhawi on 8/19/17.
//  Copyright © 2017 Mohamed Elkamhawi. All rights reserved.
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
        
        Alamofire
            .request(baseUrl + "/" + category, parameters: parameters)
            .responseString(completionHandler: { (response: DataResponse<String>) in
                switch response.result {
                case .success(let movies):
                    print("Request: \(String(describing: response.request))")   // original url request
                    print("Response: \(String(describing: response.response))") // http url response
                    let movieCollection = Mapper<MovieCollectionDto>()
                        .map(JSONString: movies)
                    
                    movieCollection?.insert(into: category, deleteOldData: page == 1, completionHandler: completionHandler)
                case .failure(let error):
                    print("Error: NetworkOperation getMovies: \(error)")
                
                }
            })
    }
    
    public func getMovieDetails(movieId: String) {
        let parameters = [
            "api_key": apiKey,
            "append_to_response": "trailers,reviews"
        ]
        
        Alamofire
            .request(baseUrl + "/" + movieId, parameters: parameters)
            .responseString(completionHandler: { (response: DataResponse<String>) in
                switch response.result {
                case .success(let movie):
                    print("Request: \(String(describing: response.request))")   // original url request
                    print("Response: \(String(describing: response.response))") // http url response
                    let movieDetails = Mapper<MovieDto>()
                        .map(JSONString: movie)
                    
                    MovieDto.update(movieDto: movieDetails!)
                case .failure(let error):
                    print("Error: NetworkOperation getMovieDetails: \(error)")
                }
            })
    }
}
