//
//  MovieGrid.swift
//  ios-movies-app
//
//  Created by mkamhawi on 8/19/17.
//  Copyright © 2017 Mohamed Elkamhawi. All rights reserved.
//

import UIKit

class MovieGrid: UIViewController, UICollectionViewDataSource {
    
    var networkOperations: NetworkOperations
    
    required init?(coder aDecoder: NSCoder) {
        networkOperations = NetworkOperations()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        onCategoryChanged()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var categorySegmentedControl: UISegmentedControl!
    
    
    @IBAction func onCategoryChanged() {
        if var category = categorySegmentedControl.titleForSegment(at: categorySegmentedControl.selectedSegmentIndex) {
            category = category.lowercased().replacingOccurrences(of: " ", with: "_")
            print("selected category: \(category)")
            loadMoviesBy(category: category)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
    func loadMoviesBy(category: String) {
        DispatchQueue.main.async {
            self.networkOperations.getMovies(category: category, page: 1)
        }
    }
}
