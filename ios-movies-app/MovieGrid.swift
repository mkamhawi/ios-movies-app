//
//  MovieGrid.swift
//  ios-movies-app
//
//  Created by mkamhawi on 8/19/17.
//  Copyright © 2017 Mohamed El-Kamhawi. All rights reserved.
//

import UIKit
import CoreData
import Kingfisher

class MovieGrid: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var networkOperations: NetworkOperations
    var page: Int
    var category: String
    var movies: [Movie]?
    var refresher: UIRefreshControl!
    @IBOutlet weak var movieCollectionView: UICollectionView!
    @IBOutlet weak var categorySegmentedControl: UISegmentedControl!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func onCategoryChanged() {
        if let categoryName = categorySegmentedControl.titleForSegment(at: categorySegmentedControl.selectedSegmentIndex) {
            self.category = categoryName.lowercased().replacingOccurrences(of: " ", with: "_")
            self.page = 1
            self.activityIndicator.startAnimating()
            if !loadSavedMovieData() {
                downloadMovieData()
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        networkOperations = NetworkOperations()
        movies = nil
        page = 1
        category = ""
        refresher = UIRefreshControl()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        onCategoryChanged()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(MovieGrid.refreshMovieData), for: UIControl.Event.valueChanged)
        movieCollectionView.addSubview(refresher)
        refreshCollectionCellSize()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        refreshCollectionCellSize()
    }
    
    func refreshCollectionCellSize() {
        var postersPerRow : Int
        switch UITraitCollection.current.horizontalSizeClass {
        case .compact:
            postersPerRow = 3
            if UIDevice.current.orientation != .portrait {
                postersPerRow = 6
            }
        case .regular:
            postersPerRow = 6
            if UIDevice.current.orientation != .portrait {
                postersPerRow = 9
            }
        default:
            postersPerRow = 3
        }
        let cellWidth = (UIScreen.main.bounds.width / CGFloat(postersPerRow)).rounded(.down)
        let cellHeight = cellWidth * 1.5
        print("cellWidth: \(cellWidth)\n cellHeight: \(cellHeight)")
        let cellSize = CGSize(width: cellWidth, height: cellHeight)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = cellSize
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        movieCollectionView.setCollectionViewLayout(layout, animated: true)
        movieCollectionView.reloadData()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellIdentifier = "MovieItem"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        let movieImageView: UIImageView = cell.viewWithTag(100) as! UIImageView
        if let posterPath = movies?[indexPath.item].posterPath {
            let posterUrl = URL(string: networkOperations.posterBaseUrl + posterPath)
            movieImageView.kf.setImage(with: posterUrl)
        } else {
            let posterUrl = URL(string: "http://via.placeholder.com/150x200")
            movieImageView.kf.setImage(with: posterUrl)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let numberOfMovies = movies?.count {
            if indexPath.item == numberOfMovies - 1 {
                self.page += 1
                downloadMovieData()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "movieDetailsSegue" {
            let cell = sender as! UICollectionViewCell
            if let index = self.movieCollectionView.indexPath(for: cell)?.item {
                let movieDetailsVC = segue.destination as! MovieDetailsViewController
                movieDetailsVC.movieId = movies?[index].id
            }
        }
    }

    
    func loadSavedMovieData() -> Bool {
        let request: NSFetchRequest<Movie> = Movie.fetchRequest()
        request.predicate = NSPredicate(format: "ANY categories.name = %@", argumentArray: [self.category])
        request.sortDescriptors = [NSSortDescriptor(key: "popularity", ascending: false)]
        do {
            let movies = try AppDelegate.viewContext.fetch(request)
            if movies.count > 0 {
                self.movies = movies
                self.page = movies.count / 20
                movieCollectionView.reloadData()
                if self.refresher.isRefreshing {
                    self.refresher.endRefreshing()
                }
                if self.activityIndicator.isAnimating {
                    self.activityIndicator.stopAnimating()
                }
                return true
            }
            return false
        } catch {
            print("Error MovieGrid loadSavedMovies: \(error)")
        }
        if self.activityIndicator.isAnimating {
            self.activityIndicator.stopAnimating()
        }
        return false
    }
    
    func downloadMovieData() {
        self.networkOperations.getMovies(category: self.category, page: self.page) {() in
            DispatchQueue.main.async {
                _ = self.loadSavedMovieData()
            }
        }
    }
    
    @objc func refreshMovieData() {
        self.page = 1
        self.downloadMovieData()
    }
}
