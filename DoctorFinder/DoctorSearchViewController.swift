//
//  DoctorSearchViewController.swift
//  DoctorFinder
//
//  Created by Sten Anderßen on 17.07.18.
//  Copyright © 2018 Sten Anderßen. All rights reserved.
//

import UIKit
import CoreLocation

/// View controller that displays a search bar and shows doctors for a given search query.
class DoctorSearchViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var searchResultsContainerView: UIView!
    
    // MARK: - Computed Variables
    
    private lazy var searchController: UISearchController? = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchBar.placeholder = "Search doctors"
        controller.hidesNavigationBarDuringPresentation = false
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.delegate = self
        return controller
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

    // The location manager that is responsible for requesting the users current location
    private lazy var locationManager: CLLocationManager = {
       let manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = 100.0
        return manager
    }()
    
    private var currentLocation: CLLocation?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        setupSearchResultsComponent()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    // MARK: - Loading data
    
    private func loadSearchResults(for query: String) {
        doctorSearchResultsComponent?.model = nil
        guard let location = currentLocation else {
            showLocationNotAvailableAlert()
            return
        }
        dataController.loadSearchResults(for: query, near: location)
    }
    
    private func loadMoreSearchResults(for query: String) {
        guard let location = currentLocation else {
            showLocationNotAvailableAlert()
            return
        }
        dataController.loadMore(for: query, near: location)
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
    
    // MARK: - Helper Methods
    
    private func showLocationNotAvailableAlert() {
        let controller = UIAlertController.locationNotAvailableAlert()
        present(controller, animated: true, completion: nil)
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
            let controller = UIAlertController.singleButtonAlert(with: title, message: message, buttonTitle: "Ok", buttonHandler: { _ in
                self.searchController?.searchBar.becomeFirstResponder()
            })
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
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        if (CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways) && CLLocationManager.locationServicesEnabled() {
            return true
        } else {
            let controller = UIAlertController.locationServicesDisabledAlert()
            present(controller, animated: true, completion: nil)
            return false
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        locationManager.stopUpdatingLocation()
    }
    
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

// MARK: - CLLocationManagerDelegate

extension DoctorSearchViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if [CLAuthorizationStatus.denied, CLAuthorizationStatus.restricted].contains(status) {
            let controller = UIAlertController.locationServicesDisabledAlert()
            present(controller, animated: true, completion: nil)
        } else {
            searchController?.searchBar.becomeFirstResponder()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.first
    }
}
