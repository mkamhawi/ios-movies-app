//
//  MovieGrid.swift
//  ios-movies-app
//
//  Created by mkamhawi on 8/19/17.
//  Copyright © 2017 Mohamed Elkamhawi. All rights reserved.
//

import UIKit
import CoreData
import Kingfisher

class MovieGrid: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var networkOperations: NetworkOperations
    var page: Int
    var category: String
    var movies: [Movie]?
    @IBOutlet weak var movieCollectionView: UICollectionView!
    @IBOutlet weak var categorySegmentedControl: UISegmentedControl!
    
    @IBAction func onCategoryChanged() {
        if let categoryName = categorySegmentedControl.titleForSegment(at: categorySegmentedControl.selectedSegmentIndex) {
            self.category = categoryName.lowercased().replacingOccurrences(of: " ", with: "_")
            self.page = 1
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
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        onCategoryChanged()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if previousTraitCollection?.horizontalSizeClass != traitCollection.horizontalSizeClass {
            switch traitCollection.horizontalSizeClass {
            case .compact:
                setupViewForCompactWidth()
            case.unspecified: fallthrough
            case.regular:
                setupViewForRegularWidth()
            }
        }
    }
    
    func setupViewForCompactWidth() {
        let font = UIFont.systemFont(ofSize: 10)
        categorySegmentedControl.setTitleTextAttributes([NSFontAttributeName: font], for: .normal)
    }

    func setupViewForRegularWidth() {
        let font = UIFont.systemFont(ofSize: 14)
        categorySegmentedControl.setTitleTextAttributes([NSFontAttributeName: font], for: .normal)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
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
                return true
            }
            return false
        } catch {
            print("Error MovieGrid loadSavedMovies: \(error)")
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
}
