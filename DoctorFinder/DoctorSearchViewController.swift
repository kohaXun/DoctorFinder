//
//  DoctorSearchViewController.swift
//  DoctorFinder
//
//  Created by Sten Anderßen on 17.07.18.
//  Copyright © 2018 Sten Anderßen. All rights reserved.
//

import UIKit

/// View controller that displays a search bar and shows doctors for a given search query.
class DoctorSearchViewController: UIViewController {
    
    // MARK: - Computed Variables
    
    private lazy var searchController: UISearchController? = {
        UISearchController(searchResultsController: nil)
    }()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the search controller
        guard let searchController = searchController else {
            return
        }
        
        searchController.searchBar.placeholder = "Search doctors"
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.searchBar.delegate = self

        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
}

extension DoctorSearchViewController: UISearchBarDelegate {
    
}

extension DoctorSearchViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}
