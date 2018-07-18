//
//  NetworkManager.swift
//  DoctorFinder
//
//  Created by Sten Anderßen on 17.07.18.
//  Copyright © 2018 Sten Anderßen. All rights reserved.
//

import Foundation
import Alamofire

/// Manager class that is responsible for any network request a view needs for displaying data from an API.
class NetworkManager {
    
    static let shared = NetworkManager()
    let session: SessionManager
    
    /// Returns network reachability as a boolean.
    var isNetworkReachable: Bool {
        return NetworkReachabilityManager()?.isReachable ?? false
    }
    
    private init() {
        // Create default url configuration
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30.0
        session = SessionManager(configuration: configuration)
        
        // Use a middleware to handle any authentication errors from the API
        let authenticationHandler = AuthenticationHandler(with: "ioschallenge@uvita.eu", password: "shouldnotbetoohard")
        session.adapter = authenticationHandler
        session.retrier = authenticationHandler
    }
    
    func searchDoctors(for searchString: String) {
        session.request(UvitaRouter.search(kind: .doctors, query: searchString))
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success:
                    if let json = response.result.value as? [String: Any] {
                        print(json)
                    }
                case .failure:
                    print("failed")
                }
        }
    }
}
