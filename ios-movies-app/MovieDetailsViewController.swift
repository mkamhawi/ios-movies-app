//
//  MovieDetailsViewController.swift
//  ios-movies-app
//
//  Created by mkamhawi on 8/27/17.
//  Copyright © 2017 Mohamed El-Kamhawi. All rights reserved.
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
    @IBOutlet weak var overview: UITextView!
    @IBOutlet weak var moviePoster: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.startAnimating()
        networkOperations = NetworkOperations()
        self.automaticallyAdjustsScrollViewInsets = false
        self.updateMovieDetails()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let headerView = tableView.tableHeaderView else {
            return
        }
        
        let size = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        
        if headerView.frame.size.height != size.height {
            headerView.frame.size.height = size.height + 8
        }
        
        tableView.tableHeaderView = headerView
        tableView.layoutIfNeeded()
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
            if movieDetails.releaseDate != nil {
                releaseDate.text = formatter.string(from: movieDetails.releaseDate! as Date)
            }
            overview.text = movieDetails.overview ?? ""
            if let posterPath = movieDetails.posterPath {
                let posterUrl = URL(string: networkOperations.posterBaseUrl + posterPath)
                moviePoster.kf.setImage(with: posterUrl)
            } else {
                let posterUrl = URL(string: "http://via.placeholder.com/150x200")
                moviePoster.kf.setImage(with: posterUrl)
            }
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if self.trailers?[indexPath.row] != nil {
                self.openTrailer(index: indexPath.row)
            } else {
                self.displayReview(index: indexPath.row)
            }
        } else {
            self.displayReview(index: indexPath.row)
        }
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func openTrailer(index: Int) {
        if self.trailers?[index] != nil {
            let trailer = self.trailers![index]
            print("\(trailer.name ?? "nil") at \(trailer.source ?? "nil")")
            if let trailerSource = trailer.source {
                let appUrl = URL(string: "youtube://\(trailerSource)")
                if UIApplication.shared.canOpenURL(appUrl!) {
                    UIApplication.shared.open(appUrl!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                } else {
                    let webUrl = URL(string: "https://www.youtube.com/watch?v=\(trailerSource)")
                    UIApplication.shared.open(webUrl!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                }
            }
        }
    }
    
    func displayReview(index: Int) {
        if self.reviews?[index] != nil {
            let review = self.reviews![index]
            performSegue(withIdentifier: "review", sender: review)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "review" {
            let reviewScene = segue.destination as! ReviewViewController
            if let review = sender as! Review? {
                reviewScene.review = review
            }
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { element in (UIApplication.OpenExternalURLOptionsKey(rawValue: element.key), element.value)})
}
