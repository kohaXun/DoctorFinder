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

enum DoctorSearchDataError: Error {
    case notFound
    case network(error: Error)
}

protocol DoctorSearchDataControllerDelegate: class {
    func dataController(_ controller: DoctorSearchDataController, didLoadData doctors: [Doctor])
    func dataController(_ controller: DoctorSearchDataController, didFail error: DoctorSearchDataError)
}


/// Data controller that handles downloading of data necessary for a view controller.
class DoctorSearchDataController {
    
    // MARK: - Variables
    weak var delegate: DoctorSearchDataControllerDelegate?
    
    /// Returns true if there are more pages to load from the API
    var canLoadMore = false
    
    private var searchTask: DataRequest?
    private var lastKey: String?
    
    // MARK: - Networking
    
    /// Loads doctors asynchronously for a given search string.
    ///
    /// - Parameter searchString: The string used for querying a movie database
    func loadSearchResults(for searchString: String) {
        do {
            searchTask = try NetworkManager.shared.searchDoctors(for: searchString, lastKey: lastKey, onSuccess: { (doctors, lastKey) in
                guard !doctors.isEmpty else {
                    self.delegate?.dataController(self, didFail: .notFound)
                    return
                }
                self.delegate?.dataController(self, didLoadData: doctors)
                self.canLoadMore = true
                self.lastKey = lastKey
            }) { error in
                self.delegate?.dataController(self, didFail: .network(error: error))
            }
        } catch (let error) {
            self.delegate?.dataController(self, didFail: .network(error: error))
        }
    }
    
    /// Loads the next page if there is any for a search query.
    ///
    /// - Parameter searchString: The string used for querying the API
    func loadMore(for searchString: String) {
        if let searchTask = searchTask, !searchTask.progress.isFinished {
            return
        }
        
        guard canLoadMore, !searchString.isEmpty else {
            return
        }
        
        do {
            searchTask = try NetworkManager.shared.searchDoctors(for: searchString, lastKey: lastKey, onSuccess: { (doctors, lastKey) in
                guard !doctors.isEmpty else {
                    self.canLoadMore = false
                    return
                }
                self.delegate?.dataController(self, didLoadData: doctors)
                self.lastKey = lastKey
            }) { error in
                self.canLoadMore = false
            }
        } catch {
            self.canLoadMore = false
        }
    }
}

