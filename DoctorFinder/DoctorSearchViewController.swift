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
    
    // MARK: - Outlets
    
    @IBOutlet private weak var searchResultsContainerView: UIView!
    
    // MARK: - Computed Variables
    
    private lazy var searchController: UISearchController? = {
        return UISearchController(searchResultsController: nil)
    }()
    
    // Component that is able to show doctors in a table view
    private lazy var doctorSearchResultsComponent: DoctorSearchResultsComponentViewController? = {
        let controller = UIStoryboard.main.instantiateViewController(withIdentifier: "DoctorSearchResultsComponentViewController") as? DoctorSearchResultsComponentViewController
        controller?.delegate = self
        return controller
    }()
    
    // The data controller that is responsible to query the network manager to load data
    private lazy var dataController: DoctorSearchDataController = {
        let controller = DoctorSearchDataController()
        controller.delegate = self
        return controller
    }()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the search controller
        guard let searchController = searchController else {
            return
        }
        
        searchController.searchBar.placeholder = "Search doctors"
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self

        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        setupSearchResultsComponent()
    }
    
    // MARK: - Loading data
    
    private func loadSearchResults(for query: String) {
        doctorSearchResultsComponent?.model = nil
        dataController.loadSearchResults(for: query)
    }
    
    private func loadMoreSearchResults(for query: String) {
        dataController.loadMore(for: query)
    }
    
    // MARK: - Updating Component
    
    private func showSearchResults(with doctors: [Doctor]) {
        if let data = doctorSearchResultsComponent?.model?.data, !data.isEmpty {
            doctorSearchResultsComponent?.model = DoctorSearchResultComponentModel(with: data + doctors)
        } else {
            doctorSearchResultsComponent?.model = DoctorSearchResultComponentModel(with: doctors)
        }
        doctorSearchResultsComponent?.view.isHidden = false
    }
    
    private func hideSearchResults() {
        doctorSearchResultsComponent?.view.isHidden = true
    }
    
    private func setupSearchResultsComponent() {
        guard let component = doctorSearchResultsComponent else {
            return
        }
        loadChildViewController(component, in: searchResultsContainerView)
        component.view.isHidden = true
    }
}

// MARK: - DoctorSearchDataControllerDelegate

extension DoctorSearchViewController: DoctorSearchDataControllerDelegate {
    func dataController(_ controller: DoctorSearchDataController, didLoadData doctors: [Doctor]) {
        showSearchResults(with: doctors)
    }
    
    func dataController(_ controller: DoctorSearchDataController, didFail error: DoctorSearchDataError) {
        switch error {
        case .notFound:
            let title = "Doctor not found"
            let message = "Sorry, there is no doctor with that name."
            let controller = UIAlertController.singleButtonAlert(with: title, message: message, buttonTitle: "Ok")
            present(controller, animated: true, completion: nil)
        case .network(let error):
            let controller = UIAlertController.alert(for: error)
            present(controller, animated: true, completion: nil)
        }
    }
}

// MARK: - DoctorSearchResultsComponentDelegate

extension DoctorSearchViewController: DoctorSearchResultsComponentDelegate {
    func componentDidDisplayLastCell(_ component: DoctorSearchResultsComponentViewController) {
        guard let searchString = searchController?.searchBar.text else {
            return
        }
        loadMoreSearchResults(for: searchString)
    }
}

// MARK: - UISearchBarDelegate

extension DoctorSearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchString = searchBar.text else {
            return
        }
        loadSearchResults(for: searchString)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        hideSearchResults()
    }
}
