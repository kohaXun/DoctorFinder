//
//  DoctorSearchDataController.swift
//  DoctorFinder
//
//  Created by Sten Anderßen on 19.07.18.
//  Copyright © 2018 Sten Anderßen. All rights reserved.
//

import Foundation
import Alamofire
import UIKit
import CoreLocation

enum DoctorSearchDataError: Error {
    case notFound
    case network(error: Error)
}

protocol DoctorSearchDataControllerDelegate: class {
    func dataController(_ controller: DoctorSearchDataController, didLoadData doctors: [Doctor])
    func dataController(_ controller: DoctorSearchDataController, didFail error: DoctorSearchDataError)
    func dataControllerDidCancel(_ controller: DoctorSearchDataController)
}


/// Data controller that handles downloading of data necessary for a view controller.
class DoctorSearchDataController {
    
    // MARK: - Variables
    weak var delegate: DoctorSearchDataControllerDelegate?
    
    /// Returns true if there are more pages to load from the API
    private var canLoadMore: Bool {
        return lastKey != nil
    }
    private var searchTask: DataRequest?
    private var lastKey: String?
    private var isCanceled = false
    
    // MARK: - Networking
    
    /// Loads doctors asynchronously for a given search string and location if there is any.
    ///
    /// - Parameter searchString: The string used for querying the API
    /// - Parameter location: The location used for querying the API
    func loadSearchResults(for searchString: String, near location: CLLocation) {
        isCanceled = false
        do {
            searchTask = try NetworkManager.shared.searchDoctors(for: searchString, near: location , onSuccess: { (doctors, lastKey) in
                guard !self.isCanceled else {
                    return
                }
                guard !doctors.isEmpty else {
                    self.delegate?.dataController(self, didFail: .notFound)
                    return
                }
                self.delegate?.dataController(self, didLoadData: doctors)
                self.lastKey = lastKey
            }) { error in
                guard !self.isCanceled else {
                    return
                }
                self.delegate?.dataController(self, didFail: .network(error: error))
            }
        } catch (let error) {
            guard !isCanceled else {
                return
            }
            self.delegate?.dataController(self, didFail: .network(error: error))
        }
    }
    
    /// Loads the next page if there is any for a search query.
    ///
    /// - Parameter searchString: The string used for querying the API
    func loadMore(for searchString: String, near location: CLLocation) {
        if let searchTask = searchTask, !searchTask.progress.isFinished {
            return
        }
        
        isCanceled = false
        
        guard canLoadMore, !searchString.isEmpty else {
            return
        }
        
        do {
            searchTask = try NetworkManager.shared.searchDoctors(for: searchString, near: location, lastKey: lastKey, onSuccess: { (doctors, lastKey) in
                guard !self.isCanceled else {
                    return
                }
                self.delegate?.dataController(self, didLoadData: doctors)
                self.lastKey = lastKey
            }) { error in
                guard !self.isCanceled else {
                    return
                }
                self.lastKey = nil
            }
        } catch {
            guard !isCanceled else {
                return
            }
            self.lastKey = nil
        }
    }
    
    func cancel() {
        isCanceled = true
        delegate?.dataControllerDidCancel(self)

        guard let searchTask = searchTask, !searchTask.progress.isFinished else {
            return
        }
        
        searchTask.cancel()
    }
}

