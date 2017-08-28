//
//  MovieDetailsViewController.swift
//  ios-movies-app
//
//  Created by mkamhawi on 8/27/17.
//  Copyright © 2017 Mohamed Elkamhawi. All rights reserved.
//

import UIKit
import CoreData
import Kingfisher

class MovieDetailsViewController: UIViewController {
    
    var movieId: Int64!
    var movieDetails: Movie!
    var networkOperations: NetworkOperations!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var tagline: UILabel!
    @IBOutlet weak var overview: UILabel!
    @IBOutlet weak var moviePoster: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        networkOperations = NetworkOperations()
        self.automaticallyAdjustsScrollViewInsets = false
        self.updateMovieDetails()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadMovieDetails() {
        let request: NSFetchRequest<Movie> = Movie.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", argumentArray: [self.movieId])
        do {
            let matches = try AppDelegate.viewContext.fetch(request)
            assert(matches.count == 1, "MovieDetailsViewController-loadMovieDetails: database inconsistency")
            self.movieDetails = matches[0]
            displayMovieDetails()
        } catch {
            print("Error MovieDetailsViewController-loadMovieDetails: \(error)")
        }
    }
    
    func displayMovieDetails() {
        if movieDetails != nil {
            movieTitle.text = movieDetails.title ?? ""
            tagline.text = movieDetails.tagline ?? ""
            overview.text = movieDetails.overview ?? ""
            if let posterPath = movieDetails.posterPath {
                let posterUrl = URL(string: networkOperations.posterBaseUrl + posterPath)
                moviePoster.kf.setImage(with: posterUrl)
            } else {
                let posterUrl = URL(string: "http://via.placeholder.com/150x200")
                moviePoster.kf.setImage(with: posterUrl)
            }
        }
    }
    
    func updateMovieDetails() {
        self.networkOperations.getMovieDetails(movieId: movieId!) {() in
            DispatchQueue.main.async {
                self.loadMovieDetails()
            }
        }
    }
}
