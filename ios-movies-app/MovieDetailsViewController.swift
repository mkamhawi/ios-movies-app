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

class MovieDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var movieId: Int64!
    var movieDetails: Movie!
    var trailers: [Trailer]?
    var reviews: [Review]?
    var networkOperations: NetworkOperations!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var tagline: UILabel!
    @IBOutlet weak var releaseDate: UILabel!
    @IBOutlet weak var overview: UILabel!
    @IBOutlet weak var moviePoster: UIImageView!
    @IBOutlet weak var tableView: UITableView!

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
            self.trailers = self.movieDetails.trailers?.allObjects as? [Trailer]
            self.reviews = self.movieDetails.reviews?.allObjects as? [Review]
            displayMovieDetails()
        } catch {
            print("Error MovieDetailsViewController-loadMovieDetails: \(error)")
        }
    }
    
    func displayMovieDetails() {
        if movieDetails != nil {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            movieTitle.text = movieDetails.title ?? ""
            tagline.text = movieDetails.tagline ?? ""
            releaseDate.text = formatter.string(from: movieDetails.releaseDate! as Date) 
            overview.text = movieDetails.overview ?? ""
            if let posterPath = movieDetails.posterPath {
                let posterUrl = URL(string: networkOperations.posterBaseUrl + posterPath)
                moviePoster.kf.setImage(with: posterUrl)
            } else {
                let posterUrl = URL(string: "http://via.placeholder.com/150x200")
                moviePoster.kf.setImage(with: posterUrl)
            }
            self.tableView.reloadData()
        }
    }
    
    func updateMovieDetails() {
        self.networkOperations.getMovieDetails(movieId: movieId!) {() in
            DispatchQueue.main.async {
                self.loadMovieDetails()
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var sectionCount = 0
        if let trailersCount = self.trailers?.count {
            sectionCount += trailersCount > 0 ? 1 : 0
        }
        
        if let reviewsCount = self.reviews?.count {
            sectionCount += reviewsCount > 0 ? 1 : 0
        }
        return sectionCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if let trailersCount = self.trailers?.count {
                return trailersCount
            }
        }
        
        if let reviewsCount = self.reviews?.count {
            return reviewsCount
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            if (self.trailers?.count) != nil {
                return "Trailers"
            }
        }
        return "Reviews"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if indexPath.section == 0 {
            if let trailersCount = self.trailers?.count, trailersCount > 0 {
                cell?.textLabel?.text = self.trailers?[indexPath.row].name
                return cell!
            }
        }
        if let reviewsCount = self.reviews?.count, reviewsCount > 0 {
            cell?.textLabel?.text = self.reviews?[indexPath.row].author
        }
        return cell!
    }
}
